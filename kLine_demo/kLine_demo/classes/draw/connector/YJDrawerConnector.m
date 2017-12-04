//
//  YJDrawerConnector.m
//  KLine
//
//  Created by 张永俊 on 2017/9/27.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJDrawerConnector.h"

@interface YJDrawerConnector()

@property (nonatomic, copy) NSArray<YJTextDrawer *> *xTexts;//x轴文字
//@property (nonatomic, copy) NSArray<YJLineDrawer *> *upVLines;//上视图纵线线
//@property (nonatomic, copy) NSArray<YJLineDrawer *> *downVLines;//下视图纵线

@property (nonatomic, assign) CGFloat upYMaxValue;//最高值
@property (nonatomic, assign) CGFloat upYMinValue;//最低值

@property (nonatomic, assign) CGFloat yMaxWidth;

@property (nonatomic, copy) NSArray<YJTextDrawer *> *upYTexts;//上视图y轴文字
@property (nonatomic, copy) NSArray<YJLineDrawer *> *upHLines;//上视图横线

@property (nonatomic, copy) NSArray<YJTextDrawer *> *downYTexts;//下视图y轴文字
@property (nonatomic, copy) NSArray<YJLineDrawer *> *downHLines;//下视图横线

@property (nonatomic, copy) NSArray<YJLineDrawer *> *centerHLines;

@property (nonatomic, assign) BOOL upTextUpdated;
@property (nonatomic, assign) BOOL downTextUpdate;

@property (nonatomic, copy) NSArray<NSString *> *downTexts;

@end

@implementation YJDrawerConnector

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.defaultTextAttributes = @{
                                                NSFontAttributeName: [YJHelper sharedHelper].fontF,
                                                 NSForegroundColorAttributeName: [YJHelper sharedHelper].color3
                                                };
        self.yMaxWidth = 0;
        self.defaultLineColor = [YJHelper sharedHelper].backgroundColor;
        self.defaultLineWidth = 1/[UIScreen mainScreen].scale;
        self.upYAccuracy = 2;
        self.downYAccuracy = 2;
        self.defaultBackgroundLineWidth = 1;
    }
    return self;
}

- (void)setDatas:(NSArray<YJStockModel *> *)datas
{
    _datas = datas;
    CGFloat upYMaxValue = [self highest:datas];
    CGFloat upYMinValue = [self lowest:datas];
    
    if (upYMaxValue == self.upYMaxValue && upYMinValue == self.upYMinValue) {
        self.upTextUpdated = NO;
    } else {
        self.upTextUpdated = YES;
    }
    
    self.upYMaxValue = upYMaxValue;
    self.upYMinValue = upYMinValue;
    
#warning 需要明确文字
    self.downTextUpdate = YES;
}

- (CGFloat)highest:(NSArray<YJStockModel *> *)datas
{
    return [YJHelper highest:datas];
}

- (CGFloat)lowest:(NSArray<YJStockModel *> *)datas
{
    return [YJHelper lowest:datas];
}

- (void)prepareUpVLinesInRect:(CGRect)rect uSpace:(CGFloat)uSpace
{
    self.upVLines = [self prepareVLinesInRect:rect uSpace:uSpace];
}

- (void)prepareDownVLinesInRect:(CGRect)rect uSpace:(CGFloat)uSpace
{
    self.downVLines = [self prepareVLinesInRect:rect uSpace:uSpace];
}

- (void)prepareDownVLinesInRect:(CGRect)rect
{
    self.downVLines = [self prepareVLinesWithLines:self.upVLines inRect:rect];
}

//子类实现
- (NSArray *)prepareVLinesInRect:(CGRect)rect uSpace:(CGFloat)uSpace
{
    NSMutableArray *vLines = [NSMutableArray array];
    
    return vLines;
}

- (NSArray<YJLineDrawer *> *)prepareVLinesWithLines:(NSArray<YJLineDrawer *> *)lines inRect:(CGRect)rect
{
    NSMutableArray *vlines = [NSMutableArray array];
    [lines enumerateObjectsUsingBlock:^(YJLineDrawer * _Nonnull line, NSUInteger idx, BOOL * _Nonnull stop) {
        YJLineDrawer *vlineDrawer = [self prepareVLineWithLine:line inRect:rect];
        
        [vlines addObject:vlineDrawer];
    }];
    return vlines;
}

- (id<YJDrawer>)prepareVLineWithLine:(YJLineDrawer *)line inRect:(CGRect)rect
{
    YJLineDrawer *vlineDrawer = [YJLineDrawer new];
    vlineDrawer.color = line.color;
    vlineDrawer.width = line.width;
    
    vlineDrawer.text = line.text;
    vlineDrawer.startPoint = CGPointMake(line.startPoint.x, CGRectGetMinY(rect));
    vlineDrawer.endPoint = CGPointMake(line.endPoint.x, CGRectGetMaxY(rect));
    
    return vlineDrawer;
}

- (void)prepareForDownHLinesInRect:(CGRect)rect paddingV:(CGFloat)paddingV lineCount:(NSInteger)count clearEdge:(BOOL)clearEdge
{
    self.downHLines = [self prepareForHLinesInRect:rect paddingV:paddingV lineCount:count clearEdge:clearEdge];
}

- (void)prepareForUpHLinesInRect:(CGRect)rect paddingV:(CGFloat)paddingV lineCount:(NSInteger)count clearEdge:(BOOL)clearEdge
{
    self.upHLines = [self prepareForHLinesInRect:rect paddingV:paddingV lineCount:count clearEdge:clearEdge];
}

- (NSArray<YJLineDrawer *> *)prepareForHLinesInRect:(CGRect)rect paddingV:(CGFloat)paddingV lineCount:(NSInteger)count clearEdge:(BOOL)clearEdge
{
    CGFloat upH = CGRectGetHeight(rect);
    NSInteger lineCount = paddingV == 0 ? count - 2 : count;
    CGFloat upLineSpace = (upH - paddingV * 2 - lineCount * self.defaultBackgroundLineWidth) / (count - 1);
    NSMutableArray *upHLines = [NSMutableArray array];
    for (NSInteger i=0; i<count; i++) {
        
        YJLineDrawer *lineModel = [YJLineDrawer new];
        lineModel.color = clearEdge && (paddingV == 0 && (i == 0 || i == count - 1)) ? [UIColor clearColor] : self.defaultLineColor;
        lineModel.width = self.defaultBackgroundLineWidth;
        
        CGFloat lineY = paddingV + CGRectGetMinY(rect) + (lineModel.width + upLineSpace) * i;
        lineModel.startPoint = CGPointMake(CGRectGetMinX(rect), lineY);
        lineModel.endPoint = CGPointMake(CGRectGetMaxX(rect), lineY);
        if (count % 2 != 0 && i == (count - 1) / 2) {
            lineModel.dash = YES;
        } else {
            lineModel.dash = NO;
        }
        
        [upHLines addObject:lineModel];
    }
    return upHLines;
}


#pragma mark - texts

- (NSArray<YJTextDrawer *> *)prepareForUpYTexts:(NSInteger)count force:(BOOL)force updateYMaxWidth:(BOOL)updateMaxWidth
{
    if (!self.upTextUpdated && !force) return self.upYTexts;
    NSMutableString *formatStr = [NSMutableString string];
    [formatStr appendString:@"%."];
    [formatStr appendFormat:@"%zd", self.upYAccuracy];
    [formatStr appendString:@"f"];
    
    NSMutableArray *texts = [NSMutableArray array];
    CGFloat valueSpace = (self.upYMaxValue - self.upYMinValue) / (count - 1);
    for (NSInteger i=0; i<count; i++) {
        CGFloat value = self.upYMaxValue - valueSpace * i;
        NSString *str = [NSString stringWithFormat:formatStr, value];
        [texts addObject:str];
    }
    
    self.upYTexts = [self prepareForYTexts:texts updateYMaxWidth:updateMaxWidth];
    return self.upYTexts;
}

- (NSArray<YJTextDrawer *> *)prepareForDownYTexts:(YJDrawerConnecterDownType)type count:(NSInteger)count force:(BOOL)force updateYMaxWidth:(BOOL)updateMaxWidth
{
    if (!self.downTextUpdate && !force) return self.downYTexts;
    NSMutableString *formatStr = [NSMutableString string];
    [formatStr appendString:@"%."];
    [formatStr appendFormat:@"%zd", self.downYAccuracy];
    [formatStr appendString:@"f"];
    
    NSMutableArray *texts = [NSMutableArray array];
    
//    [self.downTexts enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSString *str = [NSString stringWithFormat:formatStr, obj];
//        [texts addObject:str];
//    }];
    CGFloat dealCount = [YJHelper volumest:self.datas];
    NSString *str = [NSString stringWithFormat:formatStr, dealCount];
    [texts addObject:str];
    
    self.downYTexts = [self prepareForYTexts:texts updateYMaxWidth:updateMaxWidth];
    return self.downYTexts;
}

- (NSArray<YJTextDrawer *> *)prepareForYTexts:(NSArray *)yTexts updateYMaxWidth:(BOOL)updateMaxWidth
{
    NSMutableArray *texts = [NSMutableArray array];
    for (NSInteger i=0; i<yTexts.count; i++) {
        NSString *str = yTexts[i];
        
        YJTextDrawer *textModel = [YJTextDrawer new];
        textModel.text = str;
        textModel.attributes = self.defaultTextAttributes;
        
        [texts addObject:textModel];
        
        if (updateMaxWidth) {
            self.yMaxWidth = MAX(self.yMaxWidth, CGRectGetWidth(textModel.frame));
        }
    }
    return texts;
}

- (NSArray<YJTextDrawer *> *)prepareForXTexts:(NSArray *)xTexts
{
    NSMutableArray *texts = [NSMutableArray array];
    for (NSInteger i=0; i<xTexts.count; i++) {
        NSString *str = xTexts[i];
        
        YJTextDrawer *textModel = [YJTextDrawer new];
        textModel.text = str;
        textModel.attributes = self.defaultTextAttributes;
        
        [texts addObject:textModel];
    }
    self.xTexts = texts;
    return self.xTexts;
}

- (void)fixHTexts:(NSArray<YJTextDrawer *> *)texts byLines:(NSArray<YJLineDrawer *> *)lines inRect:(CGRect)rect willHide:(BOOL(^)(NSUInteger))willHide
{
    __block YJTextDrawer *preDrawer = nil;
    [texts enumerateObjectsUsingBlock:^(YJTextDrawer * _Nonnull textDrawer, NSUInteger idx, BOOL * _Nonnull stop) {
        YJLineDrawer *lineDrawer = lines[idx];
        [textDrawer fixFrameWithMaxEdgeX:CGRectGetMaxX(rect) minEdgeX:CGRectGetMinX(rect) centerX:lineDrawer.startPoint.x centerY:CGRectGetMidY(rect)];
        
        if (idx == 0) {
            preDrawer = textDrawer;
            return ;
        }
        
        if (CGRectIntersectsRect(CGRectInset(textDrawer.frame, -15, 0), CGRectInset(preDrawer.frame, -15, 0))) {
            BOOL hidden = YES;
            if (willHide) {
                hidden = willHide(idx);
            }
            if (hidden) {
                NSMutableDictionary *attributes = textDrawer.attributes.mutableCopy;
                attributes[NSForegroundColorAttributeName] = [UIColor clearColor];
                textDrawer.attributes = attributes;
                lineDrawer.color = [UIColor clearColor];
            } else {
                preDrawer = textDrawer;
            }
        } else {
            preDrawer = textDrawer;
        }
    }];
}

- (void)fixVTexts:(NSArray<YJTextDrawer *> *)texts byLines:(NSArray<YJLineDrawer *> *)lines inRect:(CGRect)rect alinment:(NSTextAlignment)alignment force:(BOOL)force
{
    if (!force) {
        if ([texts.firstObject isEqual:self.upYTexts.firstObject] && !self.upTextUpdated) {
            return;
        } else if ([texts.firstObject isEqual:self.downYTexts.firstObject] && !self.downTextUpdate) {
            return;
        }
    }
    NSUInteger count = texts.count;
    dispatch_apply(count, dispatch_get_global_queue(0, 0), ^(size_t idx) {
        YJTextDrawer *obj = texts[idx];
        YJLineDrawer *lineModel = lines[idx];
        [obj fixFrameWithMaxWidth:CGRectGetWidth(rect)
                         maxEdgeY:lines.lastObject.startPoint.y - lines.lastObject.width
                         minEdgeY:lines.firstObject.startPoint.y + lines.firstObject.width centerY:lineModel.startPoint.y + lineModel.width * 0.5
                        alignment:alignment];
        
        
        if (count % 2 != 0 && count > 2) {
            if (idx != 0 && idx != count - 1 && idx != (count-1)/2) {
                if (self.stockType == YJStockTypeEachMinute || self.stockType == YJStockTypeFiveDay) {
                    NSMutableDictionary *attributes = obj.attributes.mutableCopy;
                    attributes[NSForegroundColorAttributeName] = [UIColor clearColor];
                    obj.attributes = attributes;
                }
            }
        }
    });
}

- (NSArray<YJLineDrawer *> *)prepareCenterHLinesInRect:(CGRect)centerRect
{
    YJLineDrawer *centerUpLine = [YJLineDrawer new];
    centerUpLine.width = self.defaultBackgroundLineWidth;
    centerUpLine.color = self.defaultLineColor;
    centerUpLine.startPoint = CGPointMake(0, self.defaultBackgroundLineWidth/2.);
    centerUpLine.endPoint = CGPointMake(CGRectGetWidth(centerRect), self.defaultBackgroundLineWidth/2.);
    
    YJLineDrawer *centerDownLine = [YJLineDrawer new];
    centerDownLine.width = self.defaultBackgroundLineWidth;
    centerDownLine.color = self.defaultLineColor;
    centerDownLine.startPoint = CGPointMake(0, CGRectGetHeight(centerRect)-self.defaultBackgroundLineWidth/2.);
    centerDownLine.endPoint = CGPointMake(CGRectGetWidth(centerRect), CGRectGetHeight(centerRect)-self.defaultBackgroundLineWidth/2.);
    
    self.centerHLines = @[centerUpLine, centerDownLine];
    return self.centerHLines;
}

@end
