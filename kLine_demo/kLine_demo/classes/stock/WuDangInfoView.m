//
//  WuDangInfoView.m
//  myJsApp
//
//  Created by 张永俊 on 2017/11/17.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "WuDangInfoView.h"
#import "YJHelper.h"

@interface WuDangCell: UIView

@property (nonatomic, strong) UILabel *leftLabel;
@property (nonatomic, strong) UILabel *centerLabel;
@property (nonatomic, strong) UILabel *rightLabel;
@property (nonatomic, strong) CALayer *rightFrameLayer;

@end

@implementation WuDangCell

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
    UILabel *leftLabel = [UILabel new];
    UILabel *centerLabel = [UILabel new];
    UILabel *rightLabel = [UILabel new];
    CALayer *frameLayer = [CALayer layer];
    
    leftLabel.text = @"--";
    centerLabel.text = @"--";
    rightLabel.text = @"--";
    
    [self addSubview:leftLabel];
    [self addSubview:centerLabel];
    [self.layer addSublayer:frameLayer];
    [self addSubview:rightLabel];
    
    _leftLabel = leftLabel;
    _rightLabel = rightLabel;
    _centerLabel = centerLabel;
    _rightFrameLayer = frameLayer;
    
    YJHelper *helper = [YJHelper sharedHelper];
    
    leftLabel.font = centerLabel.font = rightLabel.font = helper.fontK;
    leftLabel.textColor = helper.color3;
    centerLabel.textColor = helper.color3;
    rightLabel.textColor = helper.color3;
    rightLabel.textAlignment = NSTextAlignmentRight;
    centerLabel.textAlignment = NSTextAlignmentCenter;
    
    _rightFrameLayer.anchorPoint = CGPointMake(1, 0.5);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat w = (CGRectGetWidth(self.bounds) - 20) / 2.;
    CGFloat h = CGRectGetHeight(self.bounds);
    self.leftLabel.frame = (CGRect){0, 0, 20, h};
    self.centerLabel.frame = CGRectMake(20, 0, w+6, h);
    self.rightLabel.frame = CGRectMake(20+w+6, 0, w-6, h);
    CGRect bounds = self.rightFrameLayer.bounds;
    bounds.size.height = h;
    self.rightFrameLayer.bounds = bounds;
    self.rightFrameLayer.position = CGPointMake(CGRectGetWidth(self.bounds), h/2.);
}

@end

@interface WuDangInfoView()

@property (nonatomic, strong) NSMutableArray<WuDangCell *> *cells;

@end


@implementation WuDangInfoView

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
    self.cells = [NSMutableArray array];
    self.backgroundColor = [YJHelper sharedHelper].color5;
    for (NSInteger i=0; i<10; i++) {
        WuDangCell *cell = [WuDangCell new];
        [self addSubview:cell];
        
        if (i == 4) {
            UIView *lineView = [UIView new];
            [self addSubview:lineView];
            lineView.backgroundColor = [YJHelper sharedHelper].backgroundColor;
        }
        
        [self.cells addObject:cell];
    }
}

- (void)reload:(void (^)(NSUInteger, UILabel *, UILabel *, UILabel *, CALayer *))setting
{
    if (!setting) return;
    [self.cells enumerateObjectsUsingBlock:^(WuDangCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        setting(idx, obj.leftLabel, obj.centerLabel, obj.rightLabel, obj.rightFrameLayer);
    }];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat cellH = [YJHelper sharedHelper].fontK.lineHeight;
    CGFloat cellW = CGRectGetWidth(self.bounds);
    CGFloat centerH = 33;
    CGFloat lineH = 1.;
    CGFloat spaceV = (CGRectGetHeight(self.bounds) - centerH - cellH * 10 - lineH)/8.;
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat y = (cellH + spaceV) * idx;
        CGFloat h = cellH;
        if (idx == 5) {
            h = lineH;
            y = y-spaceV+centerH/2.-h/2.;
        }
        if (idx > 5) {
            y = (cellH + spaceV) * (idx - 1);
            y += centerH-spaceV;
        }
        obj.frame = CGRectMake(0, y, cellW, h);
    }];
}

@end
