//
//  YJTrendDrawerConnector.h
//  KLine
//
//  Created by 张永俊 on 2017/10/9.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJDrawerConnector.h"
#import "YJShapeDrawer.h"

@interface YJTrendDrawerConnector : YJDrawerConnector
#pragma mark - readonly

/**
 每个点的间距
 */
@property (nonatomic, assign, readonly) CGFloat avgPSpace;

/**
 分时图画笔
 */
@property (nonatomic, copy, readonly) NSArray<YJShapeDrawer *> *upTrends;

/**
 下视图画笔，成交量等
 */
@property (nonatomic, copy, readonly) NSArray<YJShapeDrawer *> *downTrends;

/**
 分时图最后一个点
 */
@property (nonatomic, assign, readonly) CGPoint endPoint;


@property (nonatomic, copy, readonly) NSArray<YJTextDrawer *> *upYTexts2;

#pragma mark - readwrite



/**
 准备分时画笔，该方法会赋值给upTrends

 @param rect 所在区域
 @param paddingV 内容上下边距
 @return 画笔集合
 */
- (NSArray<YJShapeDrawer *> *)prepareUpTrendsInRect:(CGRect)rect paddingV:(CGFloat)paddingV;

/**
 准备下视图画笔，该方法会赋值给downTrends

 @param rect 所在区域
 @param paddingV 内容上下边距
 @return 画笔集合
 */
- (NSArray<YJShapeDrawer *> *)prepareDownTrendsInRect:(CGRect)rect paddingV:(CGFloat)paddingV;


- (NSArray<YJTextDrawer *> *)prepareForUpYTexts2Force:(BOOL)force updateYMaxWidth:(BOOL)updateMaxWidth;

@end
