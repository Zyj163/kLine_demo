//
//  YJDrawerConnector.h
//  KLine
//
//  Created by 张永俊 on 2017/9/27.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJTextDrawer.h"
#import "YJLineDrawer.h"
#import "YJStockModel.h"
#import "YJHelper.h"

typedef NS_ENUM(NSUInteger, YJDrawerConnecterDownType) {
    YJDrawerConnectorDownTypeDeal,//成交量
};

@interface YJDrawerConnector : NSObject

#pragma mark - readonly
@property (nonatomic, copy, readonly) NSArray<YJTextDrawer *> *xTexts;//x轴文字

@property (nonatomic, copy, readonly) NSArray<YJTextDrawer *> *upYTexts;//上视图y轴文字
@property (nonatomic, copy, readonly) NSArray<YJLineDrawer *> *upHLines;//上视图横线

@property (nonatomic, assign, readonly) CGFloat yMaxWidth;//y轴文字的最大宽度

@property (nonatomic, copy, readonly) NSArray<YJTextDrawer *> *downYTexts;//下视图y轴文字
@property (nonatomic, copy, readonly) NSArray<YJLineDrawer *> *downHLines;//下视图横线

@property (nonatomic, copy, readonly) NSArray<YJLineDrawer *> *centerHLines;//中间区域的横线

@property (nonatomic, assign, readonly) CGFloat upYMaxValue;//最高值
@property (nonatomic, assign, readonly) CGFloat upYMinValue;//最低值

@property (nonatomic, assign, readonly) BOOL upTextUpdated;
@property (nonatomic, assign, readonly) BOOL downTextUpdate;

#pragma mark - readwrite
@property (nonatomic, assign) YJStockType stockType;//蜡烛类型（日K、周K等）

@property (nonatomic, copy) NSArray<YJStockModel *> *datas;//需要处理的数据
@property (nonatomic, copy) NSArray<YJLineDrawer *> *upVLines;//上视图纵线线
@property (nonatomic, copy) NSArray<YJLineDrawer *> *downVLines;//下视图纵线

@property (nonatomic, assign) NSInteger upYAccuracy;//保留几位小数,默认两位

@property (nonatomic, assign) NSInteger downYAccuracy;//保留几位小数,默认两位

@property (nonatomic, copy) NSDictionary *defaultTextAttributes;
@property (nonatomic, strong) UIColor *defaultLineColor;
@property (nonatomic, assign) CGFloat defaultLineWidth;
@property (nonatomic, assign) CGFloat defaultBackgroundLineWidth;

#pragma mark - 背景线条

/**
 准备上视图的纵线画笔，该方法会赋值给upVLines

 @param rect 所在区域
 @param uSpace 每条线的间距，如果是k线图，传k线的宽度+k线间距
 */
- (void)prepareUpVLinesInRect:(CGRect)rect uSpace:(CGFloat)uSpace;

/**
 准备下视图的纵线画笔，该方法会赋值给downVLines
 
 @param rect 所在区域
 @param uSpace 每条线的间距，如果是k线图，传k线的宽度+k线间距
 */
- (void)prepareDownVLinesInRect:(CGRect)rect uSpace:(CGFloat)uSpace;

/**
 准备下视图的纵线画笔，该方法会赋值给downVLines，纵线x取决于upVLines，所以要先计算好upVLines，但是该方法比上一个方法会减少计算量，优先使用

 @param rect 所在区域
 */
- (void)prepareDownVLinesInRect:(CGRect)rect;

/**
 准备纵线画笔，x取决于其他画笔

 @param lines 其他画笔
 @param rect 所在区域
 @return 画笔集合
 */
- (NSArray<YJLineDrawer *> *)prepareVLinesWithLines:(NSArray<YJLineDrawer *> *)lines inRect:(CGRect)rect;

/**
 意义同上，只是单支画笔

 @param line 其他画笔
 @param rect 所在区域
 @return 画笔
 */
- (id<YJDrawer>)prepareVLineWithLine:(YJLineDrawer *)line inRect:(CGRect)rect;

/**
 准备纵线画笔，由子类实现

 @param rect 所在区域
 @param uSpace 每条线的间距，如果是k线图，传k线的宽度+k线间距
 @return 画笔集合
 */
- (NSArray<YJLineDrawer *> *)prepareVLinesInRect:(CGRect)rect uSpace:(CGFloat)uSpace;

/**
 准备上视图横线画笔，该方法会赋值给upHLines

 @param rect 所在区域
 @param paddingV 上下内容边距
 @param count 线条数量
 @param clearEdge 当paddingV为零时，隐藏最边缘横线
 */
- (void)prepareForUpHLinesInRect:(CGRect)rect paddingV:(CGFloat)paddingV lineCount:(NSInteger)count clearEdge:(BOOL)clearEdge;

/**
 准备下视图横线画笔，该方法会赋值给downHLines
 
 @param rect 所在区域
 @param paddingV 上下内容边距
 @param count 线条数量
 @param clearEdge 当paddingV为零时，隐藏最边缘横线
 */
- (void)prepareForDownHLinesInRect:(CGRect)rect paddingV:(CGFloat)paddingV lineCount:(NSInteger)count clearEdge:(BOOL)clearEdge;

/**
 准备两条横线画笔在rect的上下边缘，该方法会赋值给centerHLines
 
 @param rect 所在区域
 @return 画笔集合
 */
- (NSArray<YJLineDrawer *> *)prepareCenterHLinesInRect:(CGRect)rect;

/**
 准备横线画笔
 
 @param rect 所在区域
 @param paddingV 上下内容边距
 @param count 线条数量
 @param clearEdge 当paddingV为零时，隐藏最边缘横线
 @return 画笔集合
 */
- (NSArray<YJLineDrawer *> *)prepareForHLinesInRect:(CGRect)rect paddingV:(CGFloat)paddingV lineCount:(NSInteger)count clearEdge:(BOOL)clearEdge;

#pragma mark - 文字

/**
 准备上视图y轴文字画笔，该方法会赋值给upYTexts

 @param count 会根据最大值最小值做平分
 @param force 是否忽略upTextUpdated
 @param updateMaxWidth 是否更新yMaxWidth
 @return 画笔集合
 */
- (NSArray<YJTextDrawer *> *)prepareForUpYTexts:(NSInteger)count force:(BOOL)force updateYMaxWidth:(BOOL)updateMaxWidth;

/**
 准备下视图y轴文字画笔，该方法会赋值给downYTexts（待完善）

 @param type 下视图类型
 @param count 平分个数
 @param force 是否忽略downTextUpdated
 @param updateMaxWidth 是否更新yMaxWidth
 @return 画笔集合
 */
- (NSArray<YJTextDrawer *> *)prepareForDownYTexts:(YJDrawerConnecterDownType)type count:(NSInteger)count force:(BOOL)force updateYMaxWidth:(BOOL)updateMaxWidth;

/**
 准备y轴文字画笔

 @param yTexts text集合
 @param updateMaxWidth 是否更新yMaxWidth
 @return 画笔集合
 */
- (NSArray<YJTextDrawer *> *)prepareForYTexts:(NSArray *)yTexts updateYMaxWidth:(BOOL)updateMaxWidth;

/**
 准备x轴文字画笔，该方法会赋值给xTexts
 
 @param xTexts text集合
 @return 画笔集合
 */
- (NSArray<YJTextDrawer *> *)prepareForXTexts:(NSArray *)xTexts;

/**
 修复x轴文字坐标及是否隐藏，依赖纵线

 @param texts 文字画笔集合
 @param lines 纵线画笔集合
 @param rect 所在区域
 @param willHide 即将隐藏的回调
 */
- (void)fixHTexts:(NSArray<YJTextDrawer *> *)texts byLines:(NSArray<YJLineDrawer *> *)lines inRect:(CGRect)rect willHide:(BOOL(^)(NSUInteger))willHide;

/**
 修复y轴文字坐标及是否隐藏，依赖横线

 @param texts 文字画笔集合
 @param lines 横线画笔集合
 @param rect 所在区域
 @param alignment 对齐方式
 @param force 是否忽略upTextUpdated或者downTextUpdated
 */
- (void)fixVTexts:(NSArray<YJTextDrawer *> *)texts byLines:(NSArray<YJLineDrawer *> *)lines inRect:(CGRect)rect alinment:(NSTextAlignment)alignment force:(BOOL)force;


- (CGFloat)highest:(NSArray<YJStockModel *> *)datas;

- (CGFloat)lowest:(NSArray<YJStockModel *> *)datas;

@end
