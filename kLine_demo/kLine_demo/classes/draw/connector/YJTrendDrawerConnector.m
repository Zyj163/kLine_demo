//
//  YJTrendDrawerConnector.m
//  KLine
//
//  Created by 张永俊 on 2017/10/9.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJTrendDrawerConnector.h"

@interface YJTrendDrawerConnector()

@property (nonatomic, copy) NSArray<YJShapeDrawer *> *upTrends;
@property (nonatomic, copy) NSArray<YJShapeDrawer *> *downTrends;
@property (nonatomic, strong) NSMutableArray<YJShapeDrawer *> *downTrendDrawers;
@property (nonatomic, copy) NSArray<id<YJDrawer>> *fiveStepDrawers;
@property (nonatomic, copy) NSArray<id<YJDrawer>> *dealDrawers;
@property (nonatomic, assign) CGFloat avgPSpace;

@property (nonatomic, assign) CGPoint endPoint;

@property (nonatomic, assign) CGFloat absYield;
@property (nonatomic, assign) CGFloat absYieldPercent;
@end

@implementation YJTrendDrawerConnector

- (void)setDatas:(NSArray<YJStockModel *> *)datas
{
    self.absYield = [[datas valueForKeyPath:@"@max.absYield"] doubleValue];
    if (!datas.firstObject.preClosePrice.doubleValue) {
        self.absYieldPercent = 0;
    } else {
        self.absYieldPercent = self.absYield/datas.firstObject.preClosePrice.doubleValue;
    }
    [super setDatas:datas];
}

- (CGFloat)highest:(NSArray<YJStockModel *> *)datas
{
    return datas.firstObject.preClosePrice.doubleValue + self.absYield;
}

- (CGFloat)lowest:(NSArray<YJStockModel *> *)datas
{
    return datas.firstObject.preClosePrice.doubleValue - self.absYield;
}

- (NSArray<YJTextDrawer *> *)prepareForUpYTexts:(NSInteger)count force:(BOOL)force updateYMaxWidth:(BOOL)updateMaxWidth
{
    NSArray<YJTextDrawer *> *texts = [super prepareForUpYTexts:count force:force updateYMaxWidth:updateMaxWidth];
    
    [texts enumerateObjectsUsingBlock:^(YJTextDrawer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx == 0) {
            NSMutableDictionary *attrs = obj.attributes.mutableCopy;
            attrs[NSForegroundColorAttributeName] = [YJHelper sharedHelper].color6;
            obj.attributes = attrs;
        } else if (idx == count - 1) {
            NSMutableDictionary *attrs = obj.attributes.mutableCopy;
            attrs[NSForegroundColorAttributeName] = [YJHelper sharedHelper].color7;
            obj.attributes = attrs;
        }
    }];
    
    return texts;
}

- (NSArray<YJTextDrawer *> *)prepareForUpYTexts2Force:(BOOL)force updateYMaxWidth:(BOOL)updateMaxWidth
{
    if (self.upTextUpdated || force) {
        NSMutableString *formatStr = [NSMutableString string];
        [formatStr appendString:@"%."];
        [formatStr appendFormat:@"%zd", self.upYAccuracy];
        [formatStr appendString:@"f"];
        
        NSMutableArray *texts2 = [NSMutableArray array];
        for (NSInteger i=0; i<2; i++) {
            NSString *format;
            if (i == 0) {
                format = [[@"+" stringByAppendingString:formatStr] stringByAppendingString:@"%%"];
            } else {
                format = [[@"-" stringByAppendingString:formatStr] stringByAppendingString:@"%%"];
            }
            NSString *str = [NSString stringWithFormat:format, self.absYieldPercent*100];
            [texts2 addObject:str];
        }
        
        _upYTexts2 = [self prepareForYTexts:texts2 updateYMaxWidth:NO];
        
        [_upYTexts2 enumerateObjectsUsingBlock:^(YJTextDrawer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                NSMutableDictionary *attrs = obj.attributes.mutableCopy;
                attrs[NSForegroundColorAttributeName] = [YJHelper sharedHelper].color6;
                obj.attributes = attrs;
            } else if (idx == 1) {
                NSMutableDictionary *attrs = obj.attributes.mutableCopy;
                attrs[NSForegroundColorAttributeName] = [YJHelper sharedHelper].color7;
                obj.attributes = attrs;
            }
        }];
    }
    return _upYTexts2;
}

- (void)fixVTexts:(NSArray<YJTextDrawer *> *)texts byLines:(NSArray<YJLineDrawer *> *)lines inRect:(CGRect)rect alinment:(NSTextAlignment)alignment force:(BOOL)force
{
    if (!force) {
        if ([texts.firstObject isEqual:self.upYTexts2.firstObject] && !self.upTextUpdated) {
            return;
        }
    }
    [super fixVTexts:texts byLines:lines inRect:rect alinment:alignment force:force];
}

- (NSMutableArray<YJShapeDrawer *> *)downTrendDrawers
{
    if (!_downTrendDrawers) {
        _downTrendDrawers = [NSMutableArray array];
    }
    return _downTrendDrawers;
}

- (NSArray<YJShapeDrawer *> *)prepareUpTrendsInRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    YJShapeDrawer *avgTrend = self.upTrends.firstObject;
    if (!avgTrend) {
        avgTrend = [YJShapeDrawer new];
        avgTrend.color = [YJHelper sharedHelper].minuteLineColor;
        avgTrend.fillColor = [YJHelper sharedHelper].minuteLineColor;
        avgTrend.drawType = YJShapDrawTypeStroke;
        avgTrend.needClose = YES;
        avgTrend.shapePath = [UIBezierPath bezierPath];
        avgTrend.lineWidth = self.defaultLineWidth;
        avgTrend.gradient = YES;
        self.upTrends = @[avgTrend];
    } else {
        [avgTrend.shapePath removeAllPoints];
    }

    CGFloat uYValue = (CGRectGetHeight(rect) - paddingV * 2) / (self.upYMaxValue - self.upYMinValue);
    
    CGFloat minuteCount = 90;//270
    CGFloat uXValue = CGRectGetWidth(rect) / minuteCount;
    
    self.avgPSpace = uXValue;
    NSMutableArray *avgPs = @[].mutableCopy;
    
    [self.datas enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        CGFloat avgY = (self.upYMaxValue - obj.nClose.doubleValue) * uYValue + CGRectGetMinY(rect) + paddingV;
        
        CGFloat x = uXValue * idx;
        
        CGPoint avgP = (CGPoint){x, avgY};
        [avgPs addObject:[NSValue valueWithCGPoint:avgP]];
        
        if (idx == 0) {
            [avgTrend.shapePath moveToPoint:avgP];
            avgTrend.closeStartPoint = CGPointMake(x, CGRectGetMaxY(rect) - paddingV);
        } else {
            [avgTrend.shapePath addLineToPoint:avgP];
        }
        
        if (idx == self.datas.count - 1) {
            avgTrend.closePoint = CGPointMake(x, CGRectGetMaxY(rect) - paddingV);
            self.endPoint = avgTrend.shapePath.currentPoint;
        }
    }];
    avgTrend.points = avgPs;
    [avgTrend resetLayers];
    return self.upTrends;
}

- (YJShapeDrawer *)downTrendDrawerAtIdx:(NSUInteger)idx
{
    YJShapeDrawer *downTrendDrawer = nil;
    if (self.downTrends.count > idx) {
        downTrendDrawer = self.downTrends[idx];
    } else {
        downTrendDrawer = [YJShapeDrawer new];
        self.downTrendDrawers[idx] = downTrendDrawer;
    }
    return downTrendDrawer;
}

- (NSArray<YJShapeDrawer *> *)prepareDownTrendsInRect:(CGRect)rect paddingV:(CGFloat)paddingV
{
    CGFloat dealCount = [YJHelper volumest:self.datas];
    CGFloat uValue = CGRectGetHeight(rect) / dealCount;
    if (self.downTrendDrawers.count > self.datas.count) {
        [self.downTrendDrawers removeObjectsInRange:(NSRange){0, self.downTrendDrawers.count - self.datas.count}];
    }
    [self.datas enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat h = obj.iVolume.doubleValue * uValue;
        CGFloat y = CGRectGetMaxY(rect) - h;
        CGFloat w = self.avgPSpace/3*2;
        CGFloat x = idx == 0 ? 0 : (self.avgPSpace * idx);
        
        YJShapeDrawer *shapeDrawer = [self downTrendDrawerAtIdx:idx];
        shapeDrawer.frame = CGRectMake(x, y, w, h);
        shapeDrawer.color = [YJHelper klineColor:obj];
        shapeDrawer.fillColor = [YJHelper klineColor:obj];
        shapeDrawer.lineWidth = self.defaultLineWidth;
        if (obj.nOpen < obj.nClose) {
            shapeDrawer.drawType = YJShapDrawTypeStroke;
        }
    }];
    
    self.downTrends = self.downTrendDrawers;
    return self.downTrends;
}

- (NSArray *)prepareVLinesInRect:(CGRect)rect uSpace:(CGFloat)uSpace
{
    NSMutableArray *lines = [NSMutableArray array];
    
    NSArray *texts = @[@"09:00", @"", @"11:30", @"", @"15:00"];
    CGFloat lineSpace = CGRectGetWidth(rect) / (texts.count - 1);
    CGFloat minY = CGRectGetMinY(rect);
    CGFloat maxY = CGRectGetHeight(rect);
    [texts enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        YJLineDrawer *line = [YJLineDrawer new];
        line.width = self.defaultBackgroundLineWidth;
        line.color = self.defaultLineColor;
        if (idx == 0 || idx == texts.count - 1) {
            line.color = [UIColor clearColor];
        }
        line.text = obj;
        line.startPoint = (CGPoint){lineSpace * idx, minY};
        line.endPoint = (CGPoint){lineSpace * idx, maxY};
        [lines addObject:line];
    }];
    
    return lines;
}

@end
