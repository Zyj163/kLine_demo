//
//  YJKLineView.m
//  KLine
//
//  Created by 张永俊 on 2017/10/10.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJKLineView.h"
#import "YJDrawerView.h"
#import "YJGestureView.h"
#import "YJKLineDrawerConnector.h"
#import "YJKLineIndicatorInfoView.h"

@interface YJKLineView() <YJDrawerViewDelegate, YJGestureViewDelegate>

@property (nonatomic, strong) YJGestureView *gestureView;

@property (nonatomic, strong) YJDrawerView *upTextView;
@property (nonatomic, strong) YJDrawerView *downTextView;
@property (nonatomic, strong) YJDrawerView *klineView;
@property (nonatomic, strong) YJDrawerView *centerView;
@property (nonatomic, strong) YJDrawerView *rectView;
@property (nonatomic, strong) YJDrawerView *upHLinesView;
@property (nonatomic, strong) YJDrawerView *downHLinesView;

@property (nonatomic, assign) NSInteger preIdx;
@property (nonatomic, assign) NSInteger currentIdx;
@property (nonatomic, assign) CGFloat tmpDistance;

@property (nonatomic, assign) CGRect preFrame;
@property (nonatomic, weak) UIView *preSuperView;

@property (nonatomic, strong) YJKLineIndicatorInfoView *indicatorInfoView;

@property (nonatomic, assign) NSInteger preFindCandleIndex;

@property (nonatomic, assign) BOOL firstDraw;

@end

@implementation YJKLineView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.currentIdx = 0;
        self.firstDraw = YES;
        [self setup];
    }
    return self;
}

- (void)setup
{
    YJGestureView *gestureView = [YJGestureView new];
    [self addSubview:gestureView];
    gestureView.delegate = self;
    self.gestureView = gestureView;
    gestureView.hasRightRefreshView = NO;
    
    YJDrawerView *upHLinesView = [YJDrawerView new];
    self.upHLinesView = upHLinesView;
    upHLinesView.delegate = self;
    [self.gestureView.scrollView addSubview:upHLinesView];
    
    
    YJDrawerView *klineView = [YJDrawerView new];
    [self.gestureView.scrollView addSubview:klineView];
    klineView.delegate = self;
    self.klineView = klineView;
    
    
    YJDrawerView *downHLinesView = [YJDrawerView new];
    self.downHLinesView = downHLinesView;
    downHLinesView.delegate = self;
    [self.gestureView.scrollView addSubview:downHLinesView];
    
    
    YJDrawerView *rectView = [YJDrawerView new];
    [self.gestureView.scrollView addSubview:rectView];
    rectView.delegate = self;
    self.rectView = rectView;
    
    
    YJDrawerView *upTextView = [YJDrawerView new];
    [self.gestureView addSubview:upTextView];
    self.upTextView = upTextView;
    
    
    YJDrawerView *downTextView = [YJDrawerView new];
    [self.gestureView addSubview:downTextView];
    downTextView.delegate = self;
    self.downTextView = downTextView;
    
    
    YJDrawerView *centerView = [YJDrawerView new];
    [self.gestureView.scrollView addSubview:centerView];
    self.centerView = centerView;
}

- (YJKLineIndicatorInfoView *)indicatorInfoView
{
    if (!_indicatorInfoView) {
        _indicatorInfoView = [YJKLineIndicatorInfoView klineIndicatorInfoView];
        _indicatorInfoView.backgroundColor = [YJHelper sharedHelper].backgroundColor;
    }
    return _indicatorInfoView;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat inset = 0;
    CGFloat centerH = [self valueScaleToViewH:0.1];
    CGFloat downH = [self valueScaleToViewH:0.2];
    CGFloat upH = CGRectGetHeight(self.bounds)-centerH-downH;
    
    CGRect upRect = CGRectMake(0, 0, self.bounds.size.width-inset*2, upH);
    CGRect downRect = CGRectMake(0, 0, self.bounds.size.width-inset*2, downH);
    
    self.gestureView.frame = CGRectMake(inset, 0, self.bounds.size.width-inset*2, upH + centerH + downH + 1);
    self.upHLinesView.frame = upRect;
    self.klineView.frame = upRect;
    self.downHLinesView.frame = CGRectOffset(downRect, 0, upH + centerH);
    self.rectView.frame = CGRectOffset(downRect, 0, upH + centerH);
    self.upTextView.frame = CGRectMake(5, 0, self.connector.yMaxWidth == 0 ? CGRectGetWidth(upRect) : self.connector.yMaxWidth, upRect.size.height);
    self.downTextView.frame = CGRectMake(CGRectGetMaxX(self.gestureView.frame)-self.connector.yMaxWidth - 5, upH + centerH + 4, self.connector.yMaxWidth == 0 ? CGRectGetWidth(self.gestureView.frame)-5 : self.connector.yMaxWidth, downH);
    self.centerView.frame = CGRectMake(0, upH, upRect.size.width, centerH);
    
    self.indicatorInfoView.frame = CGRectMake(0, -5, CGRectGetWidth(self.bounds), 38);
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

- (CGFloat)valueScaleToViewH:(CGFloat)scale
{
    return self.bounds.size.height * scale;
}

- (CGFloat)valueScaleToViewW:(CGFloat)scale
{
    return self.bounds.size.width * scale;
}

- (void)prepare
{
    CGFloat inset = 0;
    CGFloat centerH = [self valueScaleToViewH:0.1];
    CGFloat downH = [self valueScaleToViewH:0.2];
    CGFloat upH = CGRectGetHeight(self.bounds)-centerH-downH;
    CGFloat upPaddingV = 15;
    CGFloat downPaddingV = 0;
    NSInteger upLineCount = 5;
    NSInteger downLineCount = 2;
    
    
    NSInteger count = self.connector.candleCount;
    if (self.currentIdx >= self.datas.count) self.currentIdx = 0;
    if (self.datas.count - self.currentIdx < count) {
        count = self.datas.count - self.currentIdx;
    }
    self.connector.datas = [self.datas subarrayWithRange:NSMakeRange(self.currentIdx, count)];
    
    CGRect upRect = CGRectMake(0, 0, self.bounds.size.width-inset*2, upH);
    CGRect downRect = CGRectMake(0, 0, self.bounds.size.width-inset*2, downH);
    
    [self.connector prepareForUpYTexts:upLineCount force:NO updateYMaxWidth:NO];
    [self.connector prepareForDownYTexts:YJDrawerConnectorDownTypeDeal count:downLineCount force:NO updateYMaxWidth:NO];
    
    if (self.firstDraw) {
        [self.connector prepareForUpHLinesInRect:upRect paddingV:upPaddingV lineCount:upLineCount clearEdge:YES];
        
        [self.connector prepareForDownHLinesInRect:downRect paddingV:downPaddingV lineCount:downLineCount clearEdge:YES];
    }
    
    
    [self.connector prepareCandlesInRect:upRect paddingV:upPaddingV volumeInRect:downRect paddingV2:downPaddingV];
    
    [self.connector prepareForXTexts:[self.connector.upVLines valueForKeyPath:@"text"]];
    
    [self.connector fixVTexts:self.connector.upYTexts byLines:self.connector.upHLines inRect:(CGRect){CGPointZero, {self.connector.yMaxWidth == 0 ? CGFLOAT_MAX : self.connector.yMaxWidth, CGRectGetHeight(upRect)}} alinment:NSTextAlignmentLeft force:NO];
    [self.connector fixVTexts:self.connector.downYTexts byLines:self.connector.downHLines inRect:(CGRect){CGPointZero, {self.connector.yMaxWidth == 0 ? CGFLOAT_MAX : self.connector.yMaxWidth, CGRectGetHeight(downRect)}} alinment:NSTextAlignmentRight force:NO];
    
    CGRect centerRect = CGRectMake(0, 0, upRect.size.width, centerH);
    
    [self.connector fixHTexts:self.connector.xTexts byLines:self.connector.upVLines inRect:(CGRect){CGPointZero, centerRect.size} willHide:^BOOL(NSUInteger idx) {
        self.connector.downVLines[idx].color = [UIColor clearColor];
        return YES;
    }];
    
    if (self.firstDraw) {
        [self.connector prepareCenterHLinesInRect:centerRect];
    }
    dispatch_sync(dispatch_get_main_queue(), ^{
        self.upTextView.frame = CGRectMake(5, 0, self.connector.yMaxWidth == 0 ? CGRectGetWidth(upRect) : self.connector.yMaxWidth, upRect.size.height);
        self.downTextView.frame = CGRectMake(CGRectGetMaxX(self.gestureView.frame)-self.connector.yMaxWidth - 5, upH + centerH + 4, self.connector.yMaxWidth == 0 ? CGRectGetWidth(downRect)-5 : self.connector.yMaxWidth, downH);
    });
}

- (void)drawWithCompletionHandler:(void (^)())handler
{
    if (!handler) handler = ^{};
    if (!self.connector || !self.datas) return handler();
    if (CGRectGetHeight(self.bounds) <= 0 || CGRectGetWidth(self.bounds) <= 0) {
        return handler();
    }
    dispatch_async(self.prepareQueue, ^{
        
        [self prepare];
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (self.firstDraw) {
                [self.upHLinesView redrawWithDrawers:self.connector.upHLines, nil];
                [self.downHLinesView redrawWithDrawers:self.connector.downHLines, nil];
            }
            [self.klineView redrawWithDrawers:self.connector.upVLines, self.connector.pointCandle ? self.connector.upTrends : self.connector.candles, self.connector.MAShapes.allValues, nil];
            
            [self.rectView redrawWithDrawers:self.connector.downVLines, self.connector.shapes, nil];
            
            [self.upTextView redrawWithDrawers:self.connector.upYTexts, nil];
            [self.downTextView redrawWithDrawers:self.connector.downYTexts, nil];
            
            [self.centerView redrawWithDrawers:self.connector.xTexts,  self.connector.centerHLines, nil];
            
            self.firstDraw = NO;
            
            handler();
        });
    });
}

- (void)draw
{
    [self drawWithCompletionHandler:nil];
}

#pragma mark - YJDrawerViewDelegate

- (BOOL)gestureView:(YJGestureView *)gestureView shouldResetDisWithMoving:(CGFloat)distance
{
    if (self.currentIdx == self.datas.count - self.connector.candleCount && distance > 0) {
        [gestureView startDragOnLeftEdge];
        return YES;
    } else {
        [gestureView endDragOnLeftEdge];
    }
    
    if (self.currentIdx == 0 && distance < 0) {
        [gestureView startDragOnRightEdge];
        return YES;
    } else {
        [gestureView endDragOnRightEdge];
    }
    
    self.tmpDistance += distance;
    NSInteger i = floor(self.tmpDistance / (self.connector.candleWidth + self.connector.candleSpace));
    NSInteger idx = i + self.preIdx;
    if (ABS(idx - self.currentIdx) < 1) return YES;
    self.currentIdx = idx;
    if (self.currentIdx < 0) self.currentIdx = 0;
    if (self.currentIdx > self.datas.count - self.connector.candleCount) self.currentIdx = self.datas.count - self.connector.candleCount;
    
    [self draw];
    return YES;
}

- (void)gestureView:(YJGestureView *)gestureView gestureStateChanged:(UIGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if ([gesture isKindOfClass:[UIPanGestureRecognizer class]]) {
            self.tmpDistance = 0;
            self.preIdx = self.currentIdx;
        } else if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
            self.preFindCandleIndex = 0;
        }
    }
    if (gesture.state == UIGestureRecognizerStateEnded) {
        if ([gesture isKindOfClass:[UILongPressGestureRecognizer class]]) {
            [gestureView hideIndicator];
            [self.indicatorInfoView removeFromSuperview];
        }
    }
    
}

- (BOOL)gestureView:(YJGestureView *)gestureView shouldResetScale:(CGFloat)scale centerPoint:(CGPoint)centerPoint
{
    NSInteger count = [self.connector suggestCandleCountInRect:self.klineView.bounds withScale:scale];
    if (count == self.connector.candleCount) return YES;
    
    CGFloat space = 0;
    CGFloat expectW = [self.connector calculateCandleWidthByCount:count inRect:self.klineView.bounds withSpace:&space];
    if (expectW > self.connector.maxCandleWidth ||
        expectW < 2)
        return YES;
    
    if (!self.preFindCandleIndex) {
        BOOL find = NO;
        NSInteger index = [self.connector indexOfCandleAtPoint:centerPoint ifFind:&find];
        if (find) {
            self.preFindCandleIndex = index + self.currentIdx;
        }
    }
    if (self.preFindCandleIndex) {
        //获取candle中心点在屏幕的位置
        CGFloat candleCenterX = centerPoint.x;
        //计算重新绘制后这个candle右边可以有几个candle
        CGFloat w = space + expectW;
        NSInteger rightCount = floor((CGRectGetWidth(self.klineView.bounds) - candleCenterX - w/2)/w);
        NSInteger rightStartIndex = self.preFindCandleIndex - rightCount;
        self.currentIdx = rightStartIndex;
    }
    if (self.currentIdx < 0) {
        self.currentIdx = 0;
    }
    if (self.currentIdx + count > self.datas.count) {
        self.currentIdx = self.datas.count - count;
    }
    if (self.currentIdx < 0) {
        self.currentIdx = 0;
    }
    if (count > self.datas.count) {
        count = self.datas.count - self.currentIdx;
    }
    
    self.connector.candleCount = count;
    [self draw];
    return YES;
}

- (void)gestureView:(YJGestureView *)gestureView didLongPressOn:(CGPoint)point
{
    [gestureView showIndicatorAtLocation:point.x];
    if (!self.indicatorInfoView.superview) {
        [self.superview.superview addSubview:self.indicatorInfoView];
        self.indicatorInfoView.frame = CGRectMake(0, CGRectGetMinY(self.frame) - 35, CGRectGetWidth(self.bounds), 38);
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

- (void)gestureView:(YJGestureView *)gestureView didTapOn:(CGPoint)point
{
    if ([self.delegate respondsToSelector:@selector(stockView:beTapedOn:)]) {
        [self.delegate stockView:self beTapedOn:point];
    }
}

- (void)gestureView:(YJGestureView *)gestureView vindicatorLocationChanged:(CGFloat)location
{
    [self.connector.candles enumerateObjectsUsingBlock:^(YJCandleDrawer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectGetMinX(obj.shapeDrawer.frame) <= location && CGRectGetMaxX(obj.shapeDrawer.frame) + self.connector.candleSpace >= location) {
            
            [self setIndicatorContentForCandle:obj atIndex:idx inGestureView:gestureView location:location];
            
            YJStockModel *stock = self.connector.datas[idx];
            [self setInfoViewWithStock:stock];
            
            *stop = YES;
        }
    }];
}

- (void)setIndicatorContentForCandle:(YJCandleDrawer *)obj atIndex:(NSUInteger)idx inGestureView:(YJGestureView *)gestureView location:(CGFloat)location
{
    NSString *hlabelText = [NSString stringWithFormat:@"%.2f", self.connector.datas[idx].nHigh.doubleValue];
    
    NSString *vlabelText = [YJHelper formatTimeFrom:self.connector.datas[idx] withType:YJStockTypeNone];
    
    gestureView.indicatorWindow.labelHeight = CGRectGetHeight(self.centerView.bounds);
    
    [gestureView fixHIndicatorLocation:CGRectGetMidY(obj.shapeDrawer.frame) withHText:hlabelText vIndicatorLocation:location centerY:CGRectGetMidY(self.centerView.frame) withVText:vlabelText];
}

- (void)setInfoViewWithStock:(YJStockModel *)stock
{
    YJHelper *helper = [YJHelper sharedHelper];
    UIColor *c;
    if (stock.nClose.doubleValue > stock.preClosePrice.doubleValue) {
        c = helper.color6;
    } else if (stock.nClose.doubleValue < stock.preClosePrice.doubleValue) {
        c = helper.color7;
    } else {
        c = helper.color1;
    }
    self.indicatorInfoView.topFirstLabel.text = [YJHelper formatTimeFrom:stock withType:YJStockTypeDay];
    
    self.indicatorInfoView.topSecondValueLabel.text = [NSString stringWithFormat:@"%.2f", stock.nOpen.doubleValue];
    self.indicatorInfoView.topSecondValueLabel.textColor = c;
    
    self.indicatorInfoView.topThirdValueLabel.text = [NSString stringWithFormat:@"%.2f", stock.nHigh.doubleValue];
    self.indicatorInfoView.topThirdValueLabel.textColor = c;
    
    self.indicatorInfoView.topForthValueLabel.text = [NSString stringWithFormat:@"%@%.2f%%", stock.yield.doubleValue > 0 ? @"+" : @"", stock.changePercent.doubleValue];
    
    self.indicatorInfoView.bottomFirstLabel.text = [NSString stringWithFormat:@"星期%@", [YJHelper weekDay:stock.week]];
    
    self.indicatorInfoView.bottomSecondValueLabel.text = [NSString stringWithFormat:@"%.2f", stock.nClose.doubleValue];
    self.indicatorInfoView.bottomSecondValueLabel.textColor = c;
    
    self.indicatorInfoView.bottomThirdValueLabel.text = [NSString stringWithFormat:@"%.2f", stock.nLow.doubleValue];
    self.indicatorInfoView.bottomThirdValueLabel.textColor = c;
    
    self.indicatorInfoView.bottomForthValueLabel.text = stock.iVolume.stringValue;
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
