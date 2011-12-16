//
//  UILabel+Utilities.m
//  MrSparkle
//
//  Created by Josh Svatek on 11-12-15.
//  Copyright (c) 2011 Threebit. All rights reserved.
//

#import "UILabel+Utilities.h"
#import <CoreText/CoreText.h>

@implementation UILabel (Utilities)

- (CGPathRef)createPathForText
{
    if ([self.text length] < 1)
        return nil;

    CTFontRef ctFont = CTFontCreateWithName((__bridge CFStringRef)self.font.fontName, self.font.pointSize, NULL);
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:(__bridge id)ctFont forKey:(__bridge NSString *)kCTFontAttributeName];
    NSAttributedString *attributedString = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
    
    CTLineRef aLine = CTLineCreateWithAttributedString((__bridge CFAttributedStringRef)attributedString);
    CFArrayRef runs = CTLineGetGlyphRuns(aLine); // Since a UILabel, just need the first
    CTRunRef aRun = CFArrayGetValueAtIndex(runs, 0);
    
    // We'll use this for centering the text like a UILabel
    CGFloat ascent, descent, leading;
    CGFloat width = CTLineGetTypographicBounds(aLine, &ascent, &descent, &leading);
    CGFloat height = ascent;// + descent + leading;
    CGPoint origin = CGPointMake(floorf(0.5 * (self.frame.size.width - width)), floorf(0.5 * (self.frame.size.height - height)));
    CGAffineTransform offset = CGAffineTransformMakeTranslation(origin.x, origin.y);
    
    // Construct the path
    CGMutablePathRef path = CGPathCreateMutable();
    CFIndex glyphCount = CTRunGetGlyphCount(aRun);
    CGPoint positions[glyphCount];
    CGGlyph glyphs[glyphCount];
    CTRunGetPositions(aRun, CFRangeMake(0, 0), positions);
    CTRunGetGlyphs(aRun, CFRangeMake(0, 0), glyphs);
    for (CFIndex i = 0; i < glyphCount; i++)
    {
        CGPoint p = positions[i];
        CGAffineTransform thisTranslation = CGAffineTransformMakeTranslation(p.x, p.y);
        CGAffineTransform t = CGAffineTransformConcat(offset, thisTranslation);
        CGGlyph glyph = glyphs[i];
        CGPathAddPath(path, NULL, CTFontCreatePathForGlyph(ctFont, glyph, &t));
    }

    CGPathRef result = CGPathCreateCopy(path);
    CFRelease(path);
    return result;
}

@end
