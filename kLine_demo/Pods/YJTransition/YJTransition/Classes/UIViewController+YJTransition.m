//
//  UIViewController+YJTranstion.m
//  YJCustomModalController
//
//  Created by zhangyongjun on 16/2/12.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "UIViewController+YJTransition.h"
#import <objc/runtime.h>

@implementation UIViewController (YJTransition)

+ (void)load
{
    Method method = class_getInstanceMethod([self class], NSSelectorFromString(@"dealloc"));
    Method my_method = class_getInstanceMethod([self class], @selector(yj_myDealloc));
    method_exchangeImplementations(my_method, method);
}

- (void)yj_myDealloc
{
    
    if (self.yj_stackDelegate) {
        self.yj_stackDelegate = nil;
    }
    
    if (self.yj_modalDelegate) {
        self.yj_modalDelegate = nil;
    }
    
    [self yj_myDealloc];
}

- (void)yj_customStackWithAnimationType:(YJTransAnimationType)type andDuration:(NSTimeInterval)duration animationIfNeed:(void(^)(BOOL gotoNext, UIView *fromView, UIView *toView))animation {
    if (![self isKindOfClass:[UINavigationController class]]) NSAssert([self isKindOfClass:[UINavigationController class]], @"controller must be navClass");
    
    if (type == YJTransAnimationTypeNone) return;
    
    self.yj_stackDelegate = nil;
    
    YJCustomTransitioningDelegate *customDelegate = [YJCustomTransitioningDelegate new];
    customDelegate.duration = duration;
    if (customDelegate.type == YJTransAnimationTypeNone || [YJTransitionHolder changeType:customDelegate.type toType:type]) {
        customDelegate.type = type;
    }
    customDelegate.animationIfCustom = animation;
    UINavigationController *nav = (UINavigationController *)self;
    nav.yj_stackDelegate = customDelegate;
    nav.delegate = customDelegate;
    
    //全局手势pop
    id target = nav.interactivePopGestureRecognizer.delegate;
    SEL handleNavigationTransition = NSSelectorFromString(@"handleNavigationTransition:");
    UIPanGestureRecognizer *pop = [[UIPanGestureRecognizer alloc]initWithTarget:target action:handleNavigationTransition];
    pop.delegate = self;
    [nav.view addGestureRecognizer:pop];
    nav.interactivePopGestureRecognizer.enabled = NO;

}

- (void)yj_customModalWithAnimationType:(YJTransAnimationType)type andDuration:(NSTimeInterval)duration animationIfNeed:(void(^)(BOOL gotoNext, UIView *fromView, UIView *toView))animation {
    
    if (type == YJTransAnimationTypeNone) return;
    
    self.yj_modalDelegate = nil;
    
    self.modalPresentationStyle = UIModalPresentationCustom;
    YJCustomTransitioningDelegate *customDelegate = [YJCustomTransitioningDelegate new];
    customDelegate.duration = duration;
    if (customDelegate.type == YJTransAnimationTypeNone || [YJTransitionHolder changeType:customDelegate.type toType:type]) {
        customDelegate.type = type;
    }
    customDelegate.animationIfCustom = animation;
    self.yj_modalDelegate = customDelegate;
    self.transitioningDelegate = customDelegate;
}

- (instancetype)initWithAnimationType:(YJTransAnimationType)type andDuration:(NSTimeInterval)duration animationIfNeed:(void(^)(BOOL gotoNext, UIView *fromView, UIView *toView))animation {
    self = [self init];
    if (self) {
        [self yj_customModalWithAnimationType:type andDuration:duration animationIfNeed:animation];
    }
    return self;
}

- (instancetype)initWithRootVC:(UIViewController *)rootVC animationType:(YJTransAnimationType)type andDuration:(NSTimeInterval)duration animationIfNeed:(void(^)(BOOL gotoNext, UIView *fromView, UIView *toView))animation {
    UINavigationController *nav = [(UINavigationController *)self initWithRootViewController:rootVC];
    if (nav) {
        [nav yj_customStackWithAnimationType:type andDuration:duration animationIfNeed:animation];
    }
    return nav;
}

- (void)setYj_modalDelegate:(YJCustomTransitioningDelegate *)yj_modalDelegate
{
    [self willChangeValueForKey:@"yj_modalDelegate"];
    objc_setAssociatedObject(self, _cmd, yj_modalDelegate, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"yj_modalDelegate"];
}

- (YJCustomTransitioningDelegate *)yj_modalDelegate
{
    return objc_getAssociatedObject(self, @selector(setYj_modalDelegate:));
}

- (void)setYj_stackDelegate:(YJCustomTransitioningDelegate *)yj_stackDelegate
{
    [self willChangeValueForKey:@"yj_stackDelegate"];
    objc_setAssociatedObject(self, _cmd, yj_stackDelegate, OBJC_ASSOCIATION_RETAIN);
    [self didChangeValueForKey:@"yj_stackDelegate"];
}

- (YJCustomTransitioningDelegate *)yj_stackDelegate
{
    return objc_getAssociatedObject(self, @selector(setYj_stackDelegate:));
}

@end
