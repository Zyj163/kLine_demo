//
//  YJCustomTransitioningDelegate.m
//  YJCustomModalController
//
//  Created by zhangyongjun on 16/2/11.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "YJCustomTransitioningDelegate.h"
#import "YJTransitionHolder.h"

@interface YJPresentationVC : UIPresentationController

@end

@implementation YJPresentationVC

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController
{
    self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController];
    if (self) {
        
    }
    return self;
}

- (CGRect)frameOfPresentedViewInContainerView {
    return self.containerView.bounds;
}

- (void)presentationTransitionWillBegin {
    [self.containerView addSubview:self.presentedView];
    NSLog(@"presentationTransitionWillBegin");
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
        NSLog(@"presentationTransitionDidEnd");
}

- (void)dismissalTransitionWillBegin {
        NSLog(@"dismissalTransitionWillBegin");
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [self.presentedView removeFromSuperview];
        NSLog(@"dismissalTransitionDidEnd");
}

@end

@implementation YJCustomTransitioningDelegate

- (UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(UIViewController *)presenting sourceViewController:(UIViewController *)source {
    return [[YJPresentationVC alloc]initWithPresentedViewController:presented presentingViewController:presenting];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    YJCustomAnimatedTransition *startA = [[YJCustomAnimatedTransition alloc]init];
    YJTransitionHolder *holder = [YJTransitionHolder new];
    holder.presented = YES;
    holder.duration = self.duration;
    holder.type = self.type;
    if (self.type == YJTransAnimationTypeCustom && _animationIfCustom) {
        holder.animation = _animationIfCustom;
    }
    startA.holder = holder;
    return startA;
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed{
    YJCustomAnimatedTransition *endA = [[YJCustomAnimatedTransition alloc]init];
    
    YJTransitionHolder *holder = [YJTransitionHolder new];
    holder.presented = NO;
    holder.duration = self.duration;
    holder.type = self.type;
    if (self.type == YJTransAnimationTypeCustom && _animationIfCustom) {
        holder.animation = _animationIfCustom;
    }
    endA.holder = holder;
    
    return endA;
}

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC {
    switch (operation) {
        case UINavigationControllerOperationPush:
        {
            YJCustomAnimatedTransition *pushA = [[YJCustomAnimatedTransition alloc]init];
            YJTransitionHolder *holder = [YJTransitionHolder new];
            holder.presented = YES;
            holder.duration = self.duration;
            holder.type = self.type;
            pushA.holder = holder;
            return pushA;
        }
        case UINavigationControllerOperationPop:
        {
            YJCustomAnimatedTransition *popA = [[YJCustomAnimatedTransition alloc]init];
            YJTransitionHolder *holder = [YJTransitionHolder new];
            holder.presented = YES;
            holder.duration = self.duration;
            holder.type = self.type;
            popA.holder = holder;
            return popA;
        }
        default:
            return nil;
    }
}

- (void)setAnimationIfCustom:(void (^)(BOOL, UIView *, UIView *))animationIfCustom
{
    if (!animationIfCustom) {
        return;
    }
    NSAssert(self.type == YJTransAnimationTypeCustom, @"you must set the type be YJAnimationTypeCustom");
    _animationIfCustom = animationIfCustom;
}

@end
