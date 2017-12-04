//
//  YJTrendView.m
//  KLine
//
//  Created by 张永俊 on 2017/10/10.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJTrendView.h"
#import "YJDrawerView.h"
#import "YJGestureView.h"
#import "YJTrendIndicatorInfoView.h"
#import "YJStockModel.h"

@interface YJTrendView() <YJGestureViewDelegate, YJDrawerViewDelegate>

@property (nonatomic, strong) YJGestureView *gestureView;
@property (nonatomic, strong) YJDrawerView *upTextView;
@property (nonatomic, strong) YJDrawerView *downTextView;
@property (nonatomic, strong) YJDrawerView *upShapeView;
@property (nonatomic, strong) YJDrawerView *centerView;
@property (nonatomic, strong) YJDrawerView *downShapeView;
@property (nonatomic, strong) YJDrawerView *upHLinesView;
@property (nonatomic, strong) YJDrawerView *downHLinesView;

@property (nonatomic, strong) YJTrendIndicatorInfoView *indicatorInfoView;

@property (nonatomic, strong) YJAnimateCircle *animateCircle;

@end

@implementation YJTrendView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [YJHelper sharedHelper].color5;
        
        [self setup];
    }
    return self;
}

- (CGFloat)valueScaleToViewH:(CGFloat)scale
{
    return self.bounds.size.height * scale;
}

- (CGFloat)valueScaleToViewW:(CGFloat)scale
{
    return self.bounds.size.width * scale;
}

- (void)setup
{
    YJGestureView *gestureView = [YJGestureView new];
    [self addSubview:gestureView];
    gestureView.delegate = self;
    gestureView.enablePanGes = NO;
    gestureView.enablePinchGes = NO;
    gestureView.hasLeftRefreshView = NO;
    gestureView.hasRightRefreshView = NO;
    self.gestureView = gestureView;
//    gestureView.clipsToBounds = NO;
    
    YJDrawerView *upHLinesView = [YJDrawerView new];
    self.upHLinesView = upHLinesView;
    upHLinesView.delegate = self;
    [self.gestureView addSubview:upHLinesView];
    
    YJDrawerView *upShapeView = [YJDrawerView new];
    [self.gestureView addSubview:upShapeView];
    upShapeView.delegate = self;
    self.upShapeView = upShapeView;
    [upShapeView setAnimateLayers:^(NSArray<CALayer *> *layers) {
        [layers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.name isEqualToString:@"shape"]) {
                CAShapeLayer *layer = (CAShapeLayer *)obj;
                [layer removeAllAnimations];
                CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:@"strokeColor"];
                
                ani.toValue = (id)[UIColor clearColor].CGColor;
                ani.repeatCount = CGFLOAT_MAX;
                ani.duration = 2;
                ani.autoreverses = YES;
                [layer addAnimation:ani forKey:nil];
            }
        }];
    }];
    
    YJDrawerView *downHLinesView = [YJDrawerView new];
    self.downHLinesView = downHLinesView;
    downHLinesView.delegate = self;
    [self.gestureView addSubview:downHLinesView];
    
    
    YJDrawerView *downShapeView = [YJDrawerView new];
    [self.gestureView addSubview:downShapeView];
    downShapeView.delegate = self;
    self.downShapeView = downShapeView;
    
    YJDrawerView *downTextView = [YJDrawerView new];
    [self.gestureView addSubview:downTextView];
    downTextView.delegate = self;
    self.downTextView = downTextView;
    
    
    YJDrawerView *centerView = [YJDrawerView new];
    [self.gestureView addSubview:centerView];
    self.centerView = centerView;
    
    
    YJDrawerView *upTextView = [YJDrawerView new];
    [self.gestureView addSubview:upTextView];
    self.upTextView = upTextView;
    
    CGFloat d = 15;
    self.animateCircle = [[YJAnimateCircle alloc] initWithFrame:(CGRect){0, 0, d, d}];
    [self.upShapeView addSubview:self.animateCircle];
    self.animateCircle.fillColor = [YJHelper sharedHelper].minuteLineColor;
    
    self.indicatorInfoView = [YJTrendIndicatorInfoView trendIndicatorInfoView];
    self.indicatorInfoView.hidden = YES;
    [self.gestureView addSubview:self.indicatorInfoView];
}

- (void)resetAnimateCircle
{
    CGPoint p = self.animateCircle.layer.position;
    [self.animateCircle removeFromSuperview];
    self.animateCircle = nil;
    CGFloat d = 15;
    self.animateCircle = [[YJAnimateCircle alloc] initWithFrame:(CGRect){0, 0, d, d}];
    [self.upShapeView addSubview:self.animateCircle];
    self.animateCircle.fillColor = [YJHelper sharedHelper].minuteLineColor;
    self.animateCircle.layer.position = p;
    [self.animateCircle startAnimate];
}

- (void)prepare
{
    CGFloat centerH = [self valueScaleToViewH:20./(225.+20.+47.)];
    CGFloat downH = [self valueScaleToViewH:47./(225.+20.+47.)];
    CGFloat upH = CGRectGetHeight(self.bounds)-centerH-downH;
    CGFloat upPaddingV = 10;
    CGFloat downPaddingV = 0;
    NSInteger upLineCount = 5;
    NSInteger downLineCount = 2;
    
    self.connector.datas = self.datas;
    
    CGRect upRect = CGRectMake(0, 0, self.bounds.size.width, upH);
    CGRect downRect = CGRectMake(0, 0, self.bounds.size.width, downH);
    
    [self.connector prepareForUpYTexts:upLineCount force:NO updateYMaxWidth:NO];
    [self.connector prepareForUpYTexts2Force:NO updateYMaxWidth:NO];
    [self.connector prepareForDownYTexts:YJDrawerConnectorDownTypeDeal count:downLineCount force:NO updateYMaxWidth:NO];
    
    [self.connector prepareForUpHLinesInRect:upRect paddingV:upPaddingV lineCount:upLineCount clearEdge:YES];
    
    [self.connector prepareForDownHLinesInRect:downRect paddingV:downPaddingV lineCount:downLineCount clearEdge:YES];
    
    [self.connector prepareUpTrendsInRect:upRect paddingV:upPaddingV];
    [self.connector prepareDownTrendsInRect:downRect paddingV:downPaddingV];
    
    [self.connector prepareUpVLinesInRect:upRect uSpace:0];
    [self.connector prepareDownVLinesInRect:downRect uSpace:0];
    
    [self.connector prepareForXTexts:[self.connector.upVLines valueForKeyPath:@"text"]];
    
    
    self.upTextView.frame = CGRectMake(0, 0, CGRectGetWidth(upRect), upRect.size.height);
    self.downTextView.frame = CGRectMake(CGRectGetMaxX(self.gestureView.frame)-self.connector.yMaxWidth - 5, upH + centerH + 4, self.connector.yMaxWidth == 0 ? CGRectGetWidth(downRect)-5 : self.connector.yMaxWidth, downH);
    
    [self.connector fixVTexts:self.connector.upYTexts byLines:self.connector.upHLines inRect:self.upTextView.bounds alinment:NSTextAlignmentLeft force:NO];
    [self.connector fixVTexts:self.connector.upYTexts2 byLines:@[self.connector.upHLines.firstObject, self.connector.upHLines.lastObject] inRect:self.upTextView.bounds alinment:NSTextAlignmentRight force:NO];
    [self.connector fixVTexts:self.connector.downYTexts byLines:self.connector.downHLines inRect:self.downTextView.bounds alinment:NSTextAlignmentRight force:NO];
    
    CGRect centerRect = CGRectMake(0, 0, upRect.size.width, centerH);
    
    [self.connector fixHTexts:self.connector.xTexts byLines:self.connector.upVLines inRect:(CGRect){CGPointZero, centerRect.size} willHide:^BOOL(NSUInteger idx) {
        return NO;
    }];
    
    [self.connector prepareCenterHLinesInRect:centerRect];
}

- (void)drawWithCompletionHandler:(void (^)())handler
{
    if (!handler) handler = ^{};
    if (!self.connector || !self.datas) return handler();
    if (CGRectGetHeight(self.bounds) <= 0 || CGRectGetWidth(self.bounds) <= 0) {
        return handler();
    }
    
    [self prepare];
    
    [self.upHLinesView redrawWithDrawers:self.connector.upHLines, nil];
    
    [self.upShapeView redrawWithDrawers:self.connector.upVLines, nil];
    [self.upShapeView representWithDrawers:self.connector.upTrends, nil];
    
    
    [self.downHLinesView redrawWithDrawers:self.connector.downHLines, nil];
    
    [self.downShapeView redrawWithDrawers:self.connector.downVLines, self.connector.downTrends, nil];
    
    [self.upTextView redrawWithDrawers:self.connector.upYTexts, self.connector.upYTexts2, nil];
    
    
    [self.downTextView redrawWithDrawers:self.connector.downYTexts, nil];
    
    [self.centerView redrawWithDrawers:self.connector.xTexts, self.connector.centerHLines, nil];
    
    if (self.connector.datas && self.connector.datas.count > 0) {
        [self.animateCircle startAnimate];
        self.animateCircle.layer.position = self.connector.endPoint;
    } else {
        [self.animateCircle stopAnimate];
    }
    
    handler();
}

- (void)draw
{
    [self drawWithCompletionHandler:nil];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat centerH = [self valueScaleToViewH:20./(225.+20.+47.)];
    CGFloat downH = [self valueScaleToViewH:47./(225.+20.+47.)];
    CGFloat upH = CGRectGetHeight(self.bounds)-centerH-downH;
    
    CGRect upRect = CGRectMake(0, 0, self.bounds.size.width, upH);
    CGRect downRect = CGRectMake(0, 0, self.bounds.size.width, downH);
    
    self.gestureView.frame = CGRectMake(0, 0, self.bounds.size.width, upH + centerH + downH + 1);
    self.upHLinesView.frame = upRect;
    self.upShapeView.frame = upRect;
    self.downHLinesView.frame = CGRectOffset(downRect, 0, upH + centerH);
    self.downShapeView.frame = CGRectOffset(downRect, 0, upH + centerH);
    self.upTextView.frame = CGRectMake(0, 0, CGRectGetWidth(upRect), upRect.size.height);
    self.downTextView.frame = CGRectMake(CGRectGetMaxX(self.gestureView.frame)-self.connector.yMaxWidth - 5, upH + centerH + 4, self.connector.yMaxWidth == 0 ? CGRectGetWidth(downRect)-5 : self.connector.yMaxWidth, downH);
    self.centerView.frame = CGRectMake(0, upH, upRect.size.width, centerH);
    
    
    self.animateCircle.layer.position = self.connector.endPoint;
    
    self.indicatorInfoView.frame = CGRectMake(0, 0, CGRectGetWidth(upRect), 13);
}

- (void)gestureView:(YJGestureView *)gestureView gestureStateChanged:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureView hideIndicator];
            self.indicatorInfoView.hidden = YES;
        }
    }
}

- (void)gestureView:(YJGestureView *)gestureView didLongPressOn:(CGPoint)point
{
    if (point.x > self.connector.endPoint.x) {
        point.x = self.connector.endPoint.x;
    } else if (point.x < 0) {
        point.x = 0;
    }
    [gestureView showIndicatorAtLocation:point.x];
    self.indicatorInfoView.hidden = NO;
}

- (void)gestureView:(YJGestureView *)gestureView vindicatorLocationChanged:(CGFloat)location
{
    __block CGPoint curP;
    __block NSInteger index;
    __block BOOL find = NO;
    [self.connector.upTrends[0].points enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint p = obj.CGPointValue;
        if (ABS(p.x - location) < self.connector.avgPSpace) {
            curP = p;
            index = idx;
            find = YES;
            *stop = YES;
        }
    }];
    
    if (find) {
        YJStockModel *trend = (YJStockModel *)self.connector.datas[index];
        
        NSString *hlabelText = [NSString stringWithFormat:@"%.2f", trend.nClose.doubleValue];
        
        NSString *vlabelText = [YJHelper formatTimeFrom:trend withType:self.connector.stockType];
        
        gestureView.indicatorWindow.labelHeight = CGRectGetHeight(self.centerView.bounds);
        
        [gestureView fixHIndicatorLocation:curP.y withHText:hlabelText vIndicatorLocation:location centerY:CGRectGetMidY(self.centerView.frame) withVText:vlabelText];
        
        [self setInfoViewWithStock:trend];
    }
}

- (void)setInfoViewWithStock:(YJStockModel *)stock
{
    YJHelper *helper = [YJHelper sharedHelper];
    
    self.indicatorInfoView.leftLabel.textColor = helper.color6;
    UIColor *centerColor;
    if (stock.nClose > stock.nOpen) {
        centerColor = helper.color7;
    } else if (stock.nClose == stock.nOpen) {
        centerColor = helper.color3;
    } else {
        centerColor = helper.color6;
    }
    self.indicatorInfoView.centerLabel.textColor = centerColor;
    self.indicatorInfoView.rightLabel.textColor = helper.color3;
    
    self.indicatorInfoView.leftLabel.text = [NSString stringWithFormat:@"均:%.2f", stock.nClose.doubleValue];
    self.indicatorInfoView.centerLabel.text = [NSString stringWithFormat:@"价:%.2f %.2f", stock.nClose.doubleValue, stock.nClose.doubleValue];
    self.indicatorInfoView.rightLabel.text = [NSString stringWithFormat:@"量:%zd万手", stock.iVolume.integerValue];
}

- (void)setLeftRefreshing:(BOOL)leftRefreshing
{
    _leftRefreshing = leftRefreshing;
    if (leftRefreshing) {
        [self.gestureView beginLeftRefreshing];
    } else {
        [self.gestureView endLeftRefreshing];
    }
}

- (void)setRightRefreshing:(BOOL)rightRefreshing
{
    _rightRefreshing = rightRefreshing;
    if (rightRefreshing) {
        [self.gestureView beginRightRefreshing];
    } else {
        [self.gestureView endRightRefreshing];
    }
}

- (void)gestureView:(YJGestureView *)gestureView didTapOn:(CGPoint)point
{
    if ([self.delegate respondsToSelector:@selector(stockView:beTapedOn:)]) {
        [self.delegate stockView:self beTapedOn:point];
    }
}

- (void)gestureViewBeganLeftRefreshing:(YJGestureView *)gestureView
{
    if ([self.delegate respondsToSelector:@selector(stockViewBeginLeftRefresh:)]) {
        [self.delegate stockViewBeginLeftRefresh:self];
    }
}

- (void)gestureViewBeganRightRefreshing:(YJGestureView *)gestureView
{
    if ([self.delegate respondsToSelector:@selector(stockViewBeginRightRefresh:)]) {
        [self.delegate stockViewBeginRightRefresh:self];
    }
}

- (void)showHUD
{
    [self.gestureView showHUD];
}
- (void)hideHUD
{
    [self.gestureView hideHUD];
}

@end
