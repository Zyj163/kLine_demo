//
//  YJKLineDrawerConnector.m
//  KLine
//
//  Created by 张永俊 on 2017/10/9.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJKLineDrawerConnector.h"

@interface YJKLineDrawerConnector()

@property (nonatomic, assign) CGFloat candleWidth;//每根蜡烛的宽度

@property (nonatomic, copy) NSArray<id<YJDrawer>> *upTrends;
@property (nonatomic, strong) NSMutableArray<YJCandleDrawer *> *candleDrawers;
@property (nonatomic, copy) NSArray<YJCandleDrawer *> *candles;
@property (nonatomic, copy) NSArray<YJShapeDrawer *> *shapes;
@property (nonatomic, strong) NSMutableArray<YJShapeDrawer *> *shapeDrawers;
@property (nonatomic, copy) NSDictionary<NSNumber *, YJShapeDrawer *> *MAShapes;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, YJShapeDrawer *> *MAShapeDrawers;

@property (nonatomic, assign) CGFloat candleSpace;
@end

@implementation YJKLineDrawerConnector

#pragma mark - init
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.candleMiddleLineW = self.defaultLineWidth;
        
        self.maxCandleWidth = 7;
        self.minCandleWidth = 3;
        self.maxCandleSpace = 3;
        self.minCandleSpace = 0;
        self.defaultCandleWidth = 5;
        self.defaultCandleSpace = 1.5;
        _candleWidth = self.defaultCandleWidth;
        _candleSpace = self.defaultCandleSpace;
        self.candleLimitWidth = 1;
    }
    return self;
}

#pragma mark - lazy property
- (NSMutableDictionary<NSNumber *,YJShapeDrawer *> *)MAShapeDrawers
{
    if (!_MAShapeDrawers) {
        _MAShapeDrawers = [NSMutableDictionary dictionary];
    }
    return _MAShapeDrawers;
}

- (NSMutableArray<YJCandleDrawer *> *)candleDrawers
{
    if (!_candleDrawers) {
        _candleDrawers = [NSMutableArray array];
    }
    return _candleDrawers;
}

- (NSMutableArray<YJShapeDrawer *> *)shapeDrawers
{
    if (!_shapeDrawers) {
        _shapeDrawers = [NSMutableArray array];
    }
    return _shapeDrawers;
}

#pragma mark - public method
- (CGFloat)calculateCandleWidthByCount:(NSInteger)count inRect:(CGRect)rect withSpace:(CGFloat *)space
{
    CGFloat totalW = CGRectGetWidth(rect);
    //设定每屏最后留蜡烛间距的空隙，开始不留空隙
    CGFloat candleWAndSpaceW = totalW / count;
    
    CGFloat scale = (self.maxCandleWidth - self.minCandleWidth) / (self.maxCandleSpace - self.minCandleSpace);
    
    CGFloat spaceW = (candleWAndSpaceW - self.minCandleWidth + self.minCandleSpace * scale) / (scale + 1);
    CGFloat candleW = candleWAndSpaceW - spaceW;
    if (space) {
        *space = spaceW;
    }
    return candleW;
}

- (NSInteger)suggestCandleCountInRect:(CGRect)rect withScale:(CGFloat)scale
{
    CGFloat expectW = (self.candleWidth + self.candleSpace) * scale;
    
    CGFloat totalW = CGRectGetWidth(rect);
    
    NSInteger suggestCount = ceil(totalW / expectW);
    
    return suggestCount;
}

- (NSInteger)indexOfCandleAtPoint:(CGPoint)point ifFind:(BOOL *)find
{
    __block NSInteger index = 0;
    [self.candleDrawers enumerateObjectsUsingBlock:^(YJCandleDrawer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectGetMinX(obj.shapeDrawer.frame) <= point.x && CGRectGetMaxX(obj.shapeDrawer.frame)+self.candleSpace >= point.x) {
            index = idx;
            *find = YES;
            *stop = YES;
        }
    }];
    return index;
}

- (void)prepareCandlesInRect:(CGRect)candleRect paddingV:(CGFloat)paddingV volumeInRect:(CGRect)volumeRect paddingV2:(CGFloat)paddingV2
{
    CGFloat uValue = 0;
    if (![self prepareCandleRect:candleRect paddingV:paddingV uValue:&uValue]) {
        return;
    }
    
    CGFloat uVolumeValue = 0;
    [self prepareVolumeRect:volumeRect paddingV:paddingV2 uValue:&uVolumeValue];
    
    if (!self.pointCandle) {
        [self.MATypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self MADrawerForCount:obj.integerValue reset:YES];
        }];
    }
    
    NSMutableArray *vUpLines = [NSMutableArray array];
    NSMutableArray *vDownLines = [NSMutableArray array];
    __block YJStockModel *preModel = nil;
    
    [self.datas enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        //ytext
        
        //candle
        [self prepareCandleWithStock:obj atIdx:idx uValue:uValue InRect:candleRect paddingV:paddingV];
        if (self.pointCandle) {
            //pointCandle
            
        } else {
            //MA
            [self.MATypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull type, NSUInteger index, BOOL * _Nonnull stop) {
                [self prepareMALine:type.integerValue withStock:obj atIdx:idx uValue:uValue paddingV:paddingV midX:CGRectGetMidX(self.candleDrawers[idx].shapeDrawer.frame)];
            }];
        }
        
        //volume
        [self prepareVolumeWithStock:obj atIdx:idx uValue:uVolumeValue inRect:volumeRect paddingV:paddingV2];
        
        //vline
        id<YJDrawer> vlineDrawer = [self prepareVLineWithStock:obj atIdx:idx inRect:candleRect uSpace:self.candleSpace + self.candleWidth preModel:preModel];
        [vUpLines addObject:vlineDrawer];
        
        id<YJDrawer> vlineDrawer2 = [self prepareVLineWithLine:(YJLineDrawer *)vlineDrawer inRect:volumeRect];
        [vDownLines addObject:vlineDrawer2];
        
        //hline
    }];
    
    self.candles = self.candleDrawers;
    self.shapes = self.shapeDrawers;
    
    if (!self.pointCandle) {
        self.MAShapes = self.MAShapeDrawers;
    }
    
    self.upVLines = vUpLines;
    self.downVLines = vDownLines;
}

- (void)prepareMAInRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    [self.MATypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self MADrawerForCount:obj.integerValue reset:YES];
    }];
    
    CGFloat totalH = CGRectGetHeight(rect) - paddingV * 2;
    CGFloat uValue = totalH / (self.upYMaxValue - self.upYMinValue);
    
    [self.datas enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull stock, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.MATypes enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger index, BOOL * _Nonnull stop) {
            [self prepareMALine:obj.integerValue withStock:stock atIdx:idx uValue:uValue paddingV:paddingV midX:CGRectGetMidX(self.candleDrawers[idx].shapeDrawer.frame)];
        }];
    }];
    
    self.MAShapes = self.MAShapeDrawers;
}

- (NSArray<id<YJDrawer>> *)prepareCandlesInRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    //点->值
    CGFloat uValue = 0;
    if (![self prepareCandleRect:rect paddingV:paddingV uValue:&uValue]) {
        return self.candles;
    }
    [self.datas enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self prepareCandleWithStock:obj atIdx:idx uValue:uValue InRect:rect paddingV:paddingV];
    }];
    self.candles = self.candleDrawers;
    return self.candleDrawers;
}

- (NSArray<id<YJDrawer>> *)prepareUpTrendsInRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    YJShapeDrawer *drawer = (YJShapeDrawer *)self.upTrends.firstObject;
    if (!drawer) {
        drawer = [YJShapeDrawer new];
        drawer.drawType = YJShapDrawTypeStroke;
        drawer.shapePath = [UIBezierPath bezierPath];
        drawer.color = [YJHelper sharedHelper].color3;
        self.upTrends = @[drawer];
    } else {
        [drawer.shapePath removeAllPoints];
    }
    
    CGFloat uYValue = (CGRectGetHeight(rect) - paddingV * 2) / (self.upYMaxValue - self.upYMinValue);
    
    CGFloat count = self.candleCount;
    CGFloat uXValue = CGRectGetWidth(rect) / count;
    [self.datas enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self preparePointCandleWithStock:obj atIdx:idx uYValue:uYValue uXValue:uXValue InRect:rect paddingV:paddingV];
    }];
    return self.upTrends;
}

- (NSArray<YJShapeDrawer *> *)prepareDownShapesInRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    CGFloat uValue = 0;
    [self prepareVolumeRect:rect paddingV:paddingV uValue:&uValue];
    [self.datas enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self prepareVolumeWithStock:obj atIdx:idx uValue:uValue inRect:rect paddingV:paddingV];
    }];
    self.shapes = self.shapeDrawers;
    return self.shapes;
}

#pragma mark - override method
- (NSArray *)prepareVLinesInRect:(CGRect)rect uSpace:(CGFloat)uSpace
{
    NSMutableArray *vLines = [NSMutableArray array];
    __block YJStockModel *preModel = nil;
    [self.datas enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        id vlineDrawer = [self prepareVLineWithStock:obj atIdx:idx inRect:rect uSpace:uSpace preModel:preModel];
        [vLines addObject:vlineDrawer];
    }];
    return vLines;
}

#pragma mark - private method
- (void)prepareVolumeRect:(CGRect)rect paddingV:(CGFloat)paddingV uValue:(CGFloat *)uValue
{
    CGFloat dealCount = [YJHelper volumest:self.datas];
    *uValue = (CGRectGetHeight(rect) - paddingV) / dealCount;
    if (self.shapeDrawers.count > self.datas.count) {
        [self.shapeDrawers removeObjectsInRange:(NSRange){0, self.shapeDrawers.count - self.datas.count}];
    }
}

- (BOOL)prepareCandleWidthAndSpaceInRect:(CGRect)rect
{
    CGFloat candleSpace = 0;
    self.candleWidth = [self calculateCandleWidthByCount:self.candleCount inRect:rect withSpace:&candleSpace];
    self.candleSpace = candleSpace;
    
    if (self.candleWidth >= self.candleLimitWidth) {
        if (self.candleWidth <= self.minCandleWidth) {
            _pointCandle = YES;
            
            self.MAShapes = nil;
        } else {
            _pointCandle = NO;
            _upTrends = nil;
        }
    } else {
        return NO;
    }
    return YES;
}

- (BOOL)prepareCandleRect:(CGRect)rect paddingV:(CGFloat)paddingV uValue:(CGFloat *)uValue
{
    BOOL goOn = [self prepareCandleWidthAndSpaceInRect:rect];
    if (!goOn) return NO;
    if (self.pointCandle) {
        self.MAShapes = nil;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [self prepareUpTrendsInRect:rect paddingV:paddingV];
        });
    } else {
        _upTrends = nil;
    }
    CGFloat totalH = CGRectGetHeight(rect) - paddingV * 2;
    //点->值
    *uValue = totalH / (self.upYMaxValue - self.upYMinValue);
    //从右往左
    if (self.candleDrawers.count > self.datas.count) {
        [self.candleDrawers removeObjectsInRange:(NSRange){0, self.candleDrawers.count-self.datas.count}];
    }
    return YES;
}


- (id<YJDrawer>)prepareCandleWithStock:(YJStockModel *)stock atIdx:(NSUInteger)idx uValue:(CGFloat)uValue InRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    CGFloat candleH = ABS(stock.nOpen.doubleValue - stock.nClose.doubleValue) * uValue ?: self.defaultLineWidth;
    CGFloat candleX = CGRectGetMaxX(rect) - (self.candleSpace + self.candleWidth) * (idx + 1);
    CGFloat candleY = (self.upYMaxValue - MAX(stock.nOpen.doubleValue, stock.nClose.doubleValue)) * uValue + CGRectGetMinY(rect) + paddingV;
    
    CGRect candleRect = CGRectMake(candleX, candleY, self.candleWidth, candleH);
    
    YJCandleDrawer *candleDrawer = [self candleDrawerAtIdx:idx];
    
    candleDrawer.shapeDrawer.frame = candleRect;
    if (stock.nOpen < stock.nClose) {
        candleDrawer.shapeDrawer.drawType = YJShapDrawTypeStroke;
    } else {
        candleDrawer.shapeDrawer.drawType = YJShapDrawTypeFill;
    }
    
    CGFloat lineW = self.candleMiddleLineW;
    CGFloat lineY = (self.upYMaxValue - stock.nHigh.doubleValue) * uValue + CGRectGetMinY(rect) + paddingV;
    CGFloat lineH = (stock.nHigh.doubleValue - stock.nLow.doubleValue) * uValue;
    CGPoint highestPoint = CGPointMake(candleX + self.candleWidth/2, lineY);
    CGPoint lowestPoint = CGPointMake(candleX + self.candleWidth/2, lineY + lineH);
    
    candleDrawer.lineDrawer.startPoint = highestPoint;
    candleDrawer.lineDrawer.endPoint = lowestPoint;
    candleDrawer.lineDrawer.width = lineW;
    
    candleDrawer.color = [YJHelper klineColor:stock];
    
    return candleDrawer;
}

- (id<YJDrawer>)preparePointCandleWithStock:(YJStockModel *)stock atIdx:(NSUInteger)idx uYValue:(CGFloat)uYValue uXValue:(CGFloat)uXValue InRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    YJShapeDrawer *drawer = (YJShapeDrawer *)self.upTrends.firstObject;
    
    CGFloat avgY = (self.upYMaxValue - stock.nClose.doubleValue) * uYValue + CGRectGetMinY(rect) + paddingV;
    
    CGFloat x = CGRectGetMaxX(rect) - uXValue * idx;
    
    CGPoint p = (CGPoint){x, avgY};
    
    if (idx == 0) {
        [drawer.shapePath moveToPoint:p];
    } else {
        [drawer.shapePath addLineToPoint:p];
    }
    
    return drawer;
}


- (id<YJDrawer>)prepareMALine:(NSUInteger)count withStock:(YJStockModel *)stock atIdx:(NSUInteger)idx uValue:(CGFloat)uValue paddingV:(CGFloat)paddingV midX:(CGFloat)x
{
    YJShapeDrawer *drawer = [self MADrawerForCount:count reset:NO];
    
#warning datas应该是所有的数据，而不仅仅是self.datas，这样计算是错的
    CGFloat close = [YJHelper avg:self.datas currentStock:stock count:count];
    
    CGFloat y = (self.upYMaxValue - close) * uValue;
    CGPoint p = CGPointMake(x, y);
    
    if (idx == 0) {
        [drawer.shapePath moveToPoint:p];
    } else {
        [drawer.shapePath addLineToPoint:p];
//        CGPoint currentP = drawer.shapePath.currentPoint;
//        if (p.y == currentP.y) {
//            [drawer.shapePath addLineToPoint:p];
//        } else {
//            CGFloat controlX1 = 0;
//            CGFloat controlX2 = 0;
//            CGFloat controlY1 = currentP.y;
//            CGFloat controlY2 = p.y;
//
//            controlX1 = currentP.x - ABS(p.x - currentP.x)/3;
//            controlX2 = currentP.x - ABS(p.x - currentP.x)/3*2;
//
//            CGPoint controlP1 = CGPointMake(controlX1, controlY1);
//            CGPoint controlP2 = CGPointMake(controlX2, controlY2);
//
//            [drawer.shapePath addCurveToPoint:p controlPoint1:controlP1 controlPoint2:controlP2];
//        }
    }
    return drawer;
}

- (id<YJDrawer>)prepareVolumeWithStock:(YJStockModel *)stock atIdx:(NSUInteger)idx uValue:(CGFloat)uValue inRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    CGFloat h = stock.iVolume.doubleValue * uValue;
    CGFloat y = CGRectGetMaxY(rect) - h;
    CGFloat w = self.candleWidth;
    CGFloat x = CGRectGetMaxX(rect) - (self.candleSpace + w) * (idx + 1);
    
    YJShapeDrawer *shapeDrawer = [self downShapeDrawerAtIdx:idx];
    shapeDrawer.frame = CGRectMake(x, y, w, h);
    shapeDrawer.color = [YJHelper klineColor:stock];
    shapeDrawer.fillColor = [YJHelper klineColor:stock];
    if (stock.nOpen <= stock.nClose) {
        shapeDrawer.drawType = YJShapDrawTypeStroke;
    } else {
        shapeDrawer.drawType = YJShapDrawTypeFill;
    }
    return shapeDrawer;
}

- (id<YJDrawer>)prepareVLineWithStock:(YJStockModel *)stock atIdx:(NSUInteger)idx inRect:(CGRect)rect uSpace:(CGFloat)uSpace preModel:(YJStockModel *)preModel
{
    if (![YJHelper stock:stock hasLineForType:self.stockType preStock:preModel]) return nil;
    
    YJLineDrawer *vlineDrawer = [YJLineDrawer new];
    vlineDrawer.color = self.defaultLineColor;
    vlineDrawer.width = self.defaultBackgroundLineWidth;
    
    CGFloat vlineX = CGRectGetMaxX(rect) - uSpace * (idx + 1) - vlineDrawer.width/2;
    vlineDrawer.startPoint = CGPointMake(vlineX, CGRectGetMinY(rect));
    vlineDrawer.endPoint = CGPointMake(vlineX, CGRectGetMaxY(rect));
    vlineDrawer.text = [YJHelper formatTimeFrom:stock withType:YJStockTypeMonth];
    
    preModel = stock;
    
    return vlineDrawer;
}

- (YJShapeDrawer *)downShapeDrawerAtIdx:(NSUInteger)idx
{
    YJShapeDrawer *shapeDrawer = nil;
    
    if (self.shapeDrawers.count > idx) {
        shapeDrawer = self.shapeDrawers[idx];
    } else {
        shapeDrawer = [YJShapeDrawer new];
        [self.shapeDrawers addObject:shapeDrawer];
    }
    
    return shapeDrawer;
}

- (YJCandleDrawer *)candleDrawerAtIdx:(NSUInteger)idx
{
    YJCandleDrawer *candleDrawer = nil;
    if (self.candles.count > idx) {
        candleDrawer = self.candleDrawers[idx];
    } else {
        candleDrawer = [YJCandleDrawer new];
        candleDrawer.lineDrawer = [YJLineDrawer new];
        candleDrawer.shapeDrawer = [YJShapeDrawer new];
        [self.candleDrawers addObject:candleDrawer];
    }
    return candleDrawer;
}

- (YJShapeDrawer *)MADrawerForCount:(NSInteger)count reset:(BOOL)reset
{
    YJShapeDrawer *drawer = [self.MAShapeDrawers objectForKey:@(count)];
    if (!drawer) {
        drawer = [YJShapeDrawer new];
        drawer.color = [YJHelper MAColor:count];
        drawer.lineWidth = self.defaultLineWidth;
        drawer.drawType = YJShapDrawTypeStroke;
        drawer.shapePath = [UIBezierPath bezierPath];
        [drawer.shapePath setLineJoinStyle:kCGLineJoinRound];
        self.MAShapeDrawers[@(count)] = drawer;
    } else {
        if (reset) {
            [drawer.shapePath removeAllPoints];
        }
    }
    return drawer;
}

















@end
