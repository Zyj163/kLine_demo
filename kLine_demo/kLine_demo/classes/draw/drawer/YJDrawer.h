//
//  YJDrawer.h
//  KLine
//
//  Created by 张永俊 on 2017/9/25.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YJDrawer<NSObject>

/**
 绘制到指定上下文

 @param ctx 指定上下文
 */
- (void)drawInContext:(CGContextRef)ctx;


- (void)resetLayers;
@property (nonatomic, copy, readonly) NSArray<CALayer *> *layers;

@end
