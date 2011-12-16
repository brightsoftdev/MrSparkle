//
//  JBSViewController.m
//  MrSparkle
//
//  Created by Josh Svatek on 11-12-15.
//  Copyright (c) 2011 Josh Svatek. All rights reserved.
//

#import "JBSViewController.h"
#import "UILabel+Utilities.h"
#import <QuartzCore/QuartzCore.h>

NSString * const kJBSStrokeAnimation = @"StrokeAnimation";
NSString * const kJBSEmitterAnimation = @"EmitterAnimation";
NSString * const kJBSSparkCellKey = @"SparkCell";
NSString * const kJBSSmokeCellKey = @"SmokeCell";

@interface JBSViewController()

@property (strong) CAShapeLayer *textShapeLayer;
@property (strong) CAEmitterLayer *emitterLayer;

- (CAShapeLayer *)shapeLayerFromLabel;

- (void)setupEmitterLayer;
- (CAEmitterCell *)sparkCell;
- (CAEmitterCell *)smokeCell;

- (void)tapHandler:(UIGestureRecognizer *)gestureRecognizer;
- (void)doAnimation;

@end

@implementation JBSViewController

@synthesize textLabel = _textLabel;
@synthesize textShapeLayer = _textShapeLayer;
@synthesize emitterLayer = _emitterLayer;


#pragma mark - View lifecycle

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    // Background
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(__bridge id)[UIColor blackColor].CGColor, (__bridge id)[UIColor darkGrayColor].CGColor, nil];
    [self.view.layer insertSublayer:gradient atIndex:0];

    // Replace the label with the shape layer
    self.textShapeLayer = [self shapeLayerFromLabel];
    self.textShapeLayer.frame = self.textLabel.frame;
    [self.view.layer addSublayer:self.textShapeLayer];
    self.textLabel.alpha = 0;
    
    // Emitter layer
    [self setupEmitterLayer];
    
    // Tap gesture
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandler:)];
    [self.view addGestureRecognizer:tapRecognizer];
}

#pragma mark - Gesture handlers

- (void)tapHandler:(UIGestureRecognizer *)gestureRecognizer
{
    [self doAnimation];
}

- (void)doAnimation
{
    CFTimeInterval duration = 5;
    
    // Animate drawing of line
    self.textShapeLayer.opacity = 1;
    CABasicAnimation *stroke = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    stroke.duration = duration;
    stroke.fromValue = [NSNumber numberWithFloat:0];
    stroke.toValue = [NSNumber numberWithFloat:1];
    stroke.removedOnCompletion = NO;
    [self.textShapeLayer addAnimation:stroke forKey:kJBSStrokeAnimation];

    // Adjust the emitter
    self.emitterLayer.birthRate = 1;
    
    // Particle animation
    CAKeyframeAnimation *sparkle = [CAKeyframeAnimation animationWithKeyPath:@"emitterPosition"];
    sparkle.path = self.textShapeLayer.path;
    sparkle.fillMode = kCAAnimationPaced;
    sparkle.duration = duration;
    [self.emitterLayer addAnimation:sparkle forKey:kJBSEmitterAnimation]; 
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, duration * 0.95 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){ 
        self.emitterLayer.birthRate = 0;
    });
}


#pragma mark - Utility

- (CAShapeLayer *)shapeLayerFromLabel
{
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = [self.textLabel createPathForText];
    shapeLayer.lineWidth = 1;
    shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    shapeLayer.fillColor = nil;
    shapeLayer.geometryFlipped = YES;   // CAShapeLayer, will you marry me?
    shapeLayer.opacity = 0;
    return shapeLayer;
}

#pragma mark - Particles

- (void)setupEmitterLayer
{
    CAEmitterLayer *emitter = [CAEmitterLayer layer];
    emitter.emitterCells = [NSArray arrayWithObjects:[self sparkCell], [self smokeCell], nil];
    emitter.emitterShape = kCAEmitterLayerPoint;
    emitter.birthRate = 0;
    
    [self.textShapeLayer addSublayer:emitter];
    self.emitterLayer = emitter;
}

- (CAEmitterCell *)sparkCell
{
    CAEmitterCell *spark = [CAEmitterCell emitterCell];
    spark.contents = (__bridge id)[UIImage imageNamed:@"spark.png"].CGImage;
    spark.birthRate = 900;
    spark.lifetime = 3;
    spark.scale = 0.1;
    spark.scaleRange = 0.2;
    spark.emissionRange = 2 * M_PI;
    spark.velocity = 60;
    spark.velocityRange = 8;
    spark.yAcceleration = -200;
    spark.alphaRange = 0.5;
    spark.alphaSpeed = -1;
    spark.spin = 1;
    spark.spinRange = 6;
    spark.alphaRange = 0.8;
    spark.redRange = 2;
    spark.greenRange = 1;
    spark.blueRange = 1;
    [spark setName:kJBSSparkCellKey];
    return spark;
}

- (CAEmitterCell *)smokeCell
{
    CAEmitterCell *smoke = [CAEmitterCell emitterCell];
    smoke.contents = (__bridge id)[UIImage imageNamed:@"smoke.png"].CGImage;
    smoke.birthRate = 5;
    smoke.lifetime = 20;
    smoke.scale = 0.1;
    smoke.scaleSpeed = 1;
    smoke.alphaRange = 0.5;
    smoke.alphaSpeed = -0.7;
    smoke.spin = 1;
    smoke.spinRange = 0.8;
    smoke.blueRange = 0.3;
    smoke.velocity = 10;
    smoke.yAcceleration = 100;
    [smoke setName:kJBSSmokeCellKey];
    return smoke;
}

@end
