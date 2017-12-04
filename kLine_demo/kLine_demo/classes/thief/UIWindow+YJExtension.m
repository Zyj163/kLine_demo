//
//  UIWindow+YJExtension.m
//  yyox
//
//  Created by ddn on 2017/1/12.
//  Copyright © 2017年 Panjiang. All rights reserved.
//

#import "UIWindow+YJExtension.h"
#import <objc/runtime.h>

NSString *const YJWindowClickOnAnimationContainer = @"YJWindowClickOnAnimationContainer";

NSString *const YJDidAddSubviewToWindow = @"YJDidAddSubviewToWindow";
NSString *const YJDidAddSubviewToWindowKey = @"YJDidAddSubviewToWindowKey";

@implementation UIWindow (YJExtension)

- (void)setYj_containerView:(UIButton *)yj_containerView
{
	[self willChangeValueForKey:@"yj_containerView"];
	objc_setAssociatedObject(self, _cmd, yj_containerView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"yj_containerView"];
}

- (UIButton *)yj_containerView
{
	return objc_getAssociatedObject(self, @selector(setYj_containerView:));
}

- (void)setYj_shown:(BOOL)yj_shown
{
	[self willChangeValueForKey:@"yj_shown"];
	objc_setAssociatedObject(self, _cmd, @(yj_shown), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"yj_shown"];
}

- (BOOL)yj_shown
{
	NSNumber *s = objc_getAssociatedObject(self, @selector(setYj_shown:));
	if (!s) {
		[self setYj_shown:NO];
		return NO;
	}
	return s.boolValue;
}

+ (void)load
{
	Method oriMethod = class_getInstanceMethod(self, @selector(didAddSubview:));
	Method myMethod = class_getInstanceMethod(self, @selector(my_didAddSubview:));
	
	method_exchangeImplementations(oriMethod, myMethod);
}

- (void)my_didAddSubview:(UIView *)subview
{
	if (![self respondsToSelector:@selector(my_didAddSubview:)]) return;
	[self my_didAddSubview:subview];
	
	[[NSNotificationCenter defaultCenter]postNotificationName:YJDidAddSubviewToWindow object:nil userInfo:@{YJDidAddSubviewToWindowKey : subview}];
}

UIWindow *yj_getCurrentWindow ()
{
	NSArray *windows = [[UIApplication sharedApplication] windows];
	UIWindow *tmpWin;
	for(NSInteger i = windows.count - 1; i >= 0; i --)
		{
		tmpWin = windows[i];
		if (tmpWin.windowLevel == UIWindowLevelNormal && tmpWin.rootViewController)
			{
			return tmpWin;
			}
		}
	return nil;
}

UIViewController *yj_getCurrentVC (UIWindow *window)
{
	if (!window) {
		window = yj_getCurrentWindow();
	}
	UIViewController *result = nil;
	
	id nextResponder = nil;
	UIView *frontView = nil;
	
	for (NSInteger i = window.subviews.count - 1; i >= 0; i --) {
		
		frontView = window.subviews[i];
		if ([frontView isKindOfClass:NSClassFromString(@"UITransitionView")]) {
			frontView = [frontView.subviews lastObject];
		}
		nextResponder = [frontView nextResponder];
		if ([nextResponder isKindOfClass:[UIViewController class]])
			result = nextResponder;
		else {
			frontView = nil;
			continue;
		}
		result = yj_topViewController(result);
		break;
	}
	if (frontView == nil) {
		result = window.rootViewController;
		result = yj_topViewController(result);
	}
	return result;
}

UIViewController *yj_topViewController(UIViewController *result)
{
	if ([result isKindOfClass:[UINavigationController class]]) {
		result = [result valueForKeyPath:@"topViewController"];
	} else if ([result isKindOfClass:[UITabBarController class]]) {
		result = [result valueForKeyPath:@"selectedViewController"];
	} else {
		return result;
	}
	return yj_topViewController(result);
}

- (void)yj_clickOnContainer:(UIButton *)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:YJWindowClickOnAnimationContainer object:nil userInfo:nil];
}

- (UIView *)yj_initialIfNotContainerView
{
	UIButton *containerView = [self yj_containerView];
	if (!containerView) {
		containerView = [UIButton new];
		[self setYj_containerView:containerView];
		containerView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
		[containerView addTarget:self action:@selector(yj_clickOnContainer:) forControlEvents:UIControlEventTouchUpInside];
	}
	return containerView;
}


- (void)yj_showInDuration:(NSTimeInterval)duration withAnimation:(void (^)(UIView *))animation
{
	if (self.yj_shown) return;
	UIView *containerView = [self yj_initialIfNotContainerView];
	
	[self addSubview:containerView];
	[self bringSubviewToFront:containerView];
	containerView.frame = self.bounds;
	
	dispatch_group_t group = dispatch_group_create();
	
	dispatch_group_enter(group);
	
	dispatch_block_t finish = ^(){
		dispatch_group_leave(group);
	};
	
	animation(containerView);
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		finish();
	});
	
	__weak typeof(self) ws = self;
	dispatch_group_notify(group, dispatch_get_main_queue(), ^{
		__strong typeof(ws) self = ws;
		[self setYj_shown:YES];
	});
}

- (void)yj_dismissInDuration:(NSTimeInterval)duration withAnimation:(void(^)(UIView *container))animation
{
	if (!self.yj_shown) return;
	
	UIView *containerView = [self yj_initialIfNotContainerView];
	
	dispatch_group_t group = dispatch_group_create();
	
	dispatch_group_enter(group);
	
	dispatch_block_t finish = ^(){
		dispatch_group_leave(group);
	};
	
	animation(containerView);
	
	dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
		finish();
	});
	
	__weak typeof(self) ws = self;
	dispatch_group_notify(group, dispatch_get_main_queue(), ^{
		__strong typeof(ws) self = ws;
		[containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
		[containerView removeFromSuperview];
		[self setYj_shown:NO];
	});
}

@end
