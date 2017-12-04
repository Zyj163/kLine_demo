//
//  YJShapeDrawer.h
//  KLine
//
//  Created by 张永俊 on 2017/9/28.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJDrawer.h"

typedef NS_ENUM(NSUInteger, YJShapDrawType) {
    YJShapDrawTypeFill,
    YJShapDrawTypeStroke,
    YJShapDrawTypeFillStroke,
};

@interface YJShapeDrawer : NSObject<YJDrawer>

/**
 路径
 */
@property (nonatomic, strong) UIBezierPath *shapePath;

/**
 矩形（与路径二选一）
 */
@property (nonatomic, assign) CGRect frame;

/**
 边框颜色
 */
@property (nonatomic, strong) UIColor *color;
@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) YJShapDrawType drawType;

/**
 是否让填充色渐变
 */
@property (nonatomic, assign) BOOL gradient;

/**
 是否需要裁剪
 */
@property (nonatomic, assign) BOOL needClose;

/**
 裁剪终点
 */
@property (nonatomic, assign) CGPoint closePoint;

/**
 裁剪起点
 */
@property (nonatomic, assign) CGPoint closeStartPoint;

/**
 裁剪线颜色
 */
@property (nonatomic, strong) UIColor *closeLineColor;

/**
 所包含的所有点
 */
@property (nonatomic, copy) NSArray *points;

/**
 所生产的layers
 */
@property (nonatomic, copy, readonly) NSArray<CALayer *> *layers;

@end
