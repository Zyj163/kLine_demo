//
//  YJLineDrawer.h
//  KLine
//
//  Created by 张永俊 on 2017/9/27.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJDrawer.h"

@interface YJLineDrawer : NSObject<YJDrawer>

/**
 线条颜色
 */
@property (nonatomic, strong) UIColor *color;

/**
 线条宽度
 */
@property (nonatomic, assign) CGFloat width;

/**
 起点
 */
@property (nonatomic, assign) CGPoint startPoint;

/**
 终点
 */
@property (nonatomic, assign) CGPoint endPoint;

/**
 是否为虚线
 */
@property (nonatomic, assign) BOOL dash;

@property (nonatomic, strong) UIBezierPath *path;

/**
 关联文本
 */
@property (nonatomic, copy) NSString *text;

/**
 使用该画笔所产生的layers
 */
@property (nonatomic, copy, readonly) NSArray<CALayer *> *layers;

@end
