//
//  YJTextDrawer.h
//  KLine
//
//  Created by 张永俊 on 2017/9/27.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJDrawer.h"

@interface YJTextDrawer : NSObject<YJDrawer>

@property (nonatomic, copy) NSString *text;
@property (nonatomic, copy) NSDictionary *attributes;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, copy, readonly) NSArray<CALayer *> *layers;

//纵向排列
- (void)fixFrameWithMaxWidth:(CGFloat)maxWidth maxEdgeY:(CGFloat)maxEdgeY minEdgeY:(CGFloat)minEdgeY centerY:(CGFloat)centerY alignment:(NSTextAlignment)alignment;

//横向排列
- (void)fixFrameWithMaxEdgeX:(CGFloat)maxEdgeX minEdgeX:(CGFloat)minEdgeX centerX:(CGFloat)centerX centerY:(CGFloat)centerY;

@end
