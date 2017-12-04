//
//  YJKLineDrawerConnector.h
//  KLine
//
//  Created by 张永俊 on 2017/10/9.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJDrawerConnector.h"
#import "YJCandleDrawer.h"

@interface YJKLineDrawerConnector : YJDrawerConnector
#pragma mark - readonly

/**
 蜡烛间距
 */
@property (nonatomic, assign, readonly) CGFloat candleSpace;

/**
 每根蜡烛的宽度
 */
@property (nonatomic, assign, readonly) CGFloat candleWidth;

/**
 是否处于缩小蜡烛到点的状态
 */
@property (nonatomic, assign, readonly) BOOL pointCandle;

/**
 代替蜡烛的线画笔，当pointCandle为yes时可用
 */
@property (nonatomic, copy, readonly) NSArray<id<YJDrawer>> *upTrends;

/**
 蜡烛画笔集合
 */
@property (nonatomic, copy, readonly) NSArray<YJCandleDrawer *> *candles;

/**
 下视图画笔集合，成交量等
 */
@property (nonatomic, copy, readonly) NSArray<YJShapeDrawer *> *shapes;

/**
 均线画笔字典，键与MATypes对应
 */
@property (nonatomic, copy, readonly) NSDictionary<NSNumber *, YJShapeDrawer *> *MAShapes;
#pragma mark - readwrite

/**
 一屏展示多少根蜡烛
 */
@property (nonatomic, assign) NSInteger candleCount;

/**
 中线宽度，默认1
 */
@property (nonatomic, assign) CGFloat candleMiddleLineW;

/**
 均线类型，例如@[@5, @10]，默认@[@5, @10, @20, @30]
 */
@property (nonatomic, copy) NSArray<NSNumber *> *MATypes;

/**
 极限宽度，默认为1
 */
@property (nonatomic, assign) CGFloat candleLimitWidth;

/**
 蜡烛可放大的最大宽度
 */
@property (nonatomic, assign) CGFloat maxCandleWidth;

/**
 蜡烛可缩小的最小宽度
 */
@property (nonatomic, assign) CGFloat minCandleWidth;

/**
 蜡烛默认初始宽度
 */
@property (nonatomic, assign) CGFloat defaultCandleWidth;

/**
 蜡烛间距可放大的最大值
 */
@property (nonatomic, assign) CGFloat maxCandleSpace;

/**
 蜡烛间距可缩小的最小值
 */
@property (nonatomic, assign) CGFloat minCandleSpace;

/**
 蜡烛间距默认值
 */
@property (nonatomic, assign) CGFloat defaultCandleSpace;

/**
 根据蜡烛个数和所在区域计算蜡烛宽度及蜡烛间距

 @param count 蜡烛个数
 @param rect 所在区域
 @param space 蜡烛间距（指针）
 @return 蜡烛宽度
 */
- (CGFloat)calculateCandleWidthByCount:(NSInteger)count inRect:(CGRect)rect withSpace:(CGFloat *)space;

/**
 根据所在区域和缩放比例计算合适的蜡烛个数

 @param rect 所在区域
 @param scale 缩放比例
 @return 蜡烛个数
 */
- (NSInteger)suggestCandleCountInRect:(CGRect)rect withScale:(CGFloat)scale;

/**
 查找包含某point的蜡烛画笔

 @param point 参考点
 @param find 是否找到（指针）
 @return 蜡烛画笔
 */
- (NSInteger)indexOfCandleAtPoint:(CGPoint)point ifFind:(BOOL *)find;

/**
 准备蜡烛画笔（包括切换为点的画笔），下视图画笔（暂时只有成交量，待扩展），上下纵线

 @param candleRect 蜡烛所在区域
 @param paddingV 蜡烛图区域上下内容边距
 @param volumeRect 下视图区域
 @param paddingV2 下视图上下内容边距
 */
- (void)prepareCandlesInRect:(CGRect)candleRect paddingV:(CGFloat)paddingV volumeInRect:(CGRect)volumeRect paddingV2:(CGFloat)paddingV2;

/**
 准备均线画笔

 @param rect 均线所在区域
 @param paddingV 均线所在区域的上下内容边距
 */
- (void)prepareMAInRect:(CGRect)rect paddingV:(CGFloat)paddingV;

/**
 单独准备蜡烛画笔（包含切换为点）

 @param rect 所在区域
 @param paddingV 内容边距
 @return 画笔集合
 */
- (NSArray<id<YJDrawer>> *)prepareCandlesInRect:(CGRect)rect paddingV:(CGFloat)paddingV;

/**
 单独准备蜡烛点画笔

 @param rect 所在区域
 @param paddingV 内容边距
 @return 画笔集合
 */
- (NSArray<id<YJDrawer>> *)prepareUpTrendsInRect:(CGRect)rect paddingV:(CGFloat)paddingV;

/**
 单独准备下视图画笔

 @param rect 所在区域
 @param paddingV 内容边距
 @return 画笔集合
 */
- (NSArray<YJShapeDrawer *> *)prepareDownShapesInRect:(CGRect)rect paddingV:(CGFloat)paddingV;

@end
