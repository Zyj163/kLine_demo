//
//  YJDrawerView.h
//  KLine
//
//  Created by 张永俊 on 2017/9/25.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJDrawer.h"
@class YJDrawerView;

@protocol YJDrawerViewDelegate<NSObject>

@optional

/**
 是否开始绘制

 @param drawerView 画布
 @return 返回值
 */
- (BOOL)drawerViewShouldBeginDraw:(YJDrawerView *)drawerView;
@optional

/**
 绘制结束

 @param drawerView 画布
 */
- (void)drawerViewDidEndDraw:(YJDrawerView *)drawerView;

@end

@interface YJDrawerView : UIView

@property (nonatomic, weak) id<YJDrawerViewDelegate> delegate;
@property (nonatomic, copy) void(^animateLayers)(NSArray<CALayer *> *);

/**
 根据传入的画笔重新绘制

 @param drawer 画笔集合
 */
- (void)redrawWithDrawers:(NSArray<id<YJDrawer>> *)drawer, ...NS_REQUIRES_NIL_TERMINATION;

- (void)representWithDrawers:(NSArray<id<YJDrawer>> *)drawer, ...NS_REQUIRES_NIL_TERMINATION;

- (void)removeDrawerToPresent:(id<YJDrawer>)drawer;
- (void)addOrUpdateDrawerToPresent:(id<YJDrawer>)drawer;

@end












