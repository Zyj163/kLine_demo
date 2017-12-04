//
//  UIViewController+YJTransition.h
//  YJCustomModalController
//
//  Created by zhangyongjun on 16/2/12.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJCustomTransitioningDelegate.h"

@interface UIViewController (YJTransition) <UIGestureRecognizerDelegate>

- (void)yj_customStackWithAnimationType:(YJTransAnimationType)type andDuration:(NSTimeInterval)duration animationIfNeed:(void(^)(BOOL gotoNext, UIView *fromView, UIView *toView))animation;
- (void)yj_customModalWithAnimationType:(YJTransAnimationType)type andDuration:(NSTimeInterval)duration animationIfNeed:(void(^)(BOOL gotoNext, UIView *fromView, UIView *toView))animation;

- (instancetype)initWithAnimationType:(YJTransAnimationType)type andDuration:(NSTimeInterval)duration animationIfNeed:(void(^)(BOOL gotoNext, UIView *fromView, UIView *toView))animation;
- (instancetype)initWithRootVC:(UIViewController *)rootVC animationType:(YJTransAnimationType)type andDuration:(NSTimeInterval)duration animationIfNeed:(void(^)(BOOL gotoNext, UIView *fromView, UIView *toView))animation;

@property (strong, nonatomic) YJCustomTransitioningDelegate *yj_modalDelegate;
@property (strong, nonatomic) YJCustomTransitioningDelegate *yj_stackDelegate;

@end
