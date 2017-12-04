//
//  YJIndicatorWindow.m
//  myJsApp
//
//  Created by 张永俊 on 2017/11/23.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "YJIndicatorWindow.h"
#import "YJHelper.h"

@interface YJIndicatorWindow()



@end

@implementation YJIndicatorWindow

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
    self.labelPaddingHorizontal = 6;
    
    _vIndicator = [UIView new];
    _hIndicator = [UIView new];
    
    [self addSubview:_vIndicator];
    [self addSubview:_hIndicator];
    _hIndicatorLabel = [UILabel new];
    _hIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_hIndicatorLabel];
    
    _vIndicatorLabel = [UILabel new];
    _vIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_vIndicatorLabel];
    
    YJHelper *helper = [YJHelper sharedHelper];
    
    self.vIndicator.backgroundColor = self.hIndicator.backgroundColor = helper.indicatorLineColor;
    self.vIndicatorLabel.backgroundColor = helper.indicatorLabelColor;
    self.hIndicatorLabel.backgroundColor = helper.indicatorLabelColor;
    self.vIndicatorLabel.font = self.hIndicatorLabel.font = helper.fontF;
    self.vIndicatorLabel.textColor = self.hIndicatorLabel.textColor = helper.indicatorTextColor;
    self.hIndicatorLabel.layer.borderColor = self.vIndicatorLabel.layer.borderColor = helper.indicatorLineColor.CGColor;
    self.hIndicatorLabel.layer.borderWidth = self.vIndicatorLabel.layer.borderWidth = 1./[UIScreen mainScreen].scale;
}

- (void)fixHIndicatorLocation:(CGFloat)hLocation withHText:(NSString *)hText vIndicatorLocation:(CGFloat)vLocation centerY:(CGFloat)centerY withVText:(NSString *)vText
{
    CGFloat lineW = 1./[UIScreen mainScreen].scale;
    
    _vIndicator.frame = CGRectMake(vLocation-lineW/2., self.indicatorInset.top, lineW, CGRectGetHeight(self.bounds)-self.indicatorInset.top-self.indicatorInset.bottom);
    
    _vIndicatorLabel.text = vText;
    [_vIndicatorLabel sizeToFit];
    CGRect f2 = _vIndicatorLabel.frame;
    f2.size.width += self.labelPaddingHorizontal;
    if (self.labelHeight) {
        f2.size.height = self.labelHeight;
    }
    f2.origin.x = vLocation-f2.size.width/2.;
    if (f2.origin.x < 0) {
        f2.origin.x = 0;
    } else if (CGRectGetMaxX(f2) > CGRectGetWidth(self.bounds)) {
        f2.origin.x = CGRectGetWidth(self.bounds) - f2.size.width;
    }
    f2.origin.y = centerY - self.labelHeight/2.;
    _vIndicatorLabel.frame = f2;
    
    
    _hIndicator.frame = CGRectMake(self.indicatorInset.left, hLocation-lineW/2., CGRectGetWidth(self.bounds)-self.indicatorInset.left-self.indicatorInset.right, lineW);
    
    _hIndicatorLabel.text = hText;
    [_hIndicatorLabel sizeToFit];
    CGRect f = _hIndicatorLabel.frame;
    f.size.width += self.labelPaddingHorizontal;
    if (self.labelHeight) {
        f.size.height = self.labelHeight;
    }
    f.origin.x = 0;
    f.origin.y = hLocation - self.labelHeight/2.;
    
    if (CGRectGetMaxX(f) >= vLocation) {
        f.origin.x = CGRectGetWidth(self.bounds)-f.size.width;
    }
    _hIndicatorLabel.frame = f;
}

@end
