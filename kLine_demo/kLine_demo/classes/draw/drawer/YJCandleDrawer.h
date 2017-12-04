//
//  YJCandleDrawer.h
//  KLine
//
//  Created by 张永俊 on 2017/9/28.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJLineDrawer.h"
#import "YJShapeDrawer.h"
#import "YJDrawer.h"

@interface YJCandleDrawer : NSObject<YJDrawer>

@property (nonatomic, strong) YJLineDrawer *lineDrawer;
@property (nonatomic, strong) YJShapeDrawer *shapeDrawer;

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, copy, readonly) NSArray<CALayer *> *layers;

@end
