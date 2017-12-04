//
//  YJCustomTransitioningDelegate.h
//  YJCustomModalController
//
//  Created by zhangyongjun on 16/2/11.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "YJCustomAnimatedTransition.h"

@interface YJCustomTransitioningDelegate : NSObject <UIViewControllerTransitioningDelegate, UINavigationControllerDelegate>

@property (assign, nonatomic) NSTimeInterval duration;
@property (assign, nonatomic) YJTransAnimationType type;

@property (copy, nonatomic) void(^animationIfCustom)(BOOL gotoNext, UIView *fromView, UIView *toView);

@end
