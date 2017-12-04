//
//  YJTabViews.h
//  myJsApp
//
//  Created by 张永俊 on 2017/11/16.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJTab.h"

typedef NS_ENUM(NSUInteger, YJTabViewsTabPosition) {
  YJTabViewsTabPositionNone,
  YJTabViewsTabPositionTop,
  YJTabViewsTabPositionBottom,
};

@interface YJTabViews : UIView

@property (nonatomic, assign) UIEdgeInsets specifyContentsInset;
@property (nonatomic, strong, readonly) YJTab *tab;

- (void)installTab:(YJTab *)tab withTitles:(NSArray<NSString *> *)titles tabH:(CGFloat)tabH position:(YJTabViewsTabPosition)position contents:(UIView *(^)(NSInteger, NSInteger))contents;

@end
