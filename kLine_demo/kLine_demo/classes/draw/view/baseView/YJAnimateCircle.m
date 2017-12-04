//
//  YJAnimateCircle.m
//  KLine
//
//  Created by 张永俊 on 2017/10/9.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJAnimateCircle.h"

@interface YJAnimateCircle()

@property (nonatomic, strong) UIView *centerLayer;
@property (nonatomic, strong) UIView *backgroundLayer;

@property (nonatomic, assign) BOOL animating;

@end

@implementation YJAnimateCircle

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.centerLayer = [UIView new];
    self.centerLayer.layer.masksToBounds = YES;
    
    self.backgroundLayer = [UIView new];
    self.backgroundLayer.layer.masksToBounds = YES;
    
    [self addSubview:self.centerLayer];
    [self addSubview:self.backgroundLayer];
    
    self.hidden = YES;
    self.animating = NO;
    self.hiddenWhenStop = YES;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat d = MIN(self.bounds.size.width, self.bounds.size.height);
    
    self.centerLayer.layer.bounds = CGRectMake(0, 0, d/3, d/3);
    self.centerLayer.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.centerLayer.layer.cornerRadius = d/6;
    
    self.backgroundLayer.layer.bounds = CGRectMake(0, 0, d/3, d/3);
    self.backgroundLayer.layer.position = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    self.backgroundLayer.layer.cornerRadius = d/6;
}

- (void)setFillColor:(UIColor *)fillColor
{
    _fillColor = fillColor;
    self.centerLayer.backgroundColor = fillColor;
    self.backgroundLayer.backgroundColor = fillColor;
}

- (void)setupAnimate
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationRepeatCount:CGFLOAT_MAX];
    [UIView setAnimationDuration:1];
    [UIView setAnimationRepeatAutoreverses:NO];
    
    self.backgroundLayer.alpha = 0;
    self.backgroundLayer.transform = CGAffineTransformMakeScale(3, 3);
    
    [UIView commitAnimations];
}

- (void)startAnimate
{
    if (!self.animating) {
        self.animating = YES;
        self.hidden = NO;
        [UIView setAnimationsEnabled:YES];
        [self setupAnimate];
    }
}

- (void)stopAnimate
{
    [UIView setAnimationsEnabled:NO];
    self.animating = NO;
    self.hidden = self.hiddenWhenStop;
}

@end
