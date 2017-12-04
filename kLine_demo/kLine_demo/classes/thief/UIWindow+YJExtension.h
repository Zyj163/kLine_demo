//
//  UIWindow+YJExtension.h
//  yyox
//
//  Created by ddn on 2017/1/12.
//  Copyright © 2017年 Panjiang. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const YJWindowClickOnAnimationContainer;

UIKIT_EXTERN NSString *const YJDidAddSubviewToWindow;
UIKIT_EXTERN NSString *const YJDidAddSubviewToWindowKey;

UIKIT_EXTERN UIWindow *yj_getCurrentWindow();
UIKIT_EXTERN UIViewController *yj_getCurrentVC(UIWindow *window);
UIKIT_EXTERN UIViewController *yj_topViewController(UIViewController *result);

@interface UIWindow (YJExtension)

- (void)yj_showInDuration:(NSTimeInterval)duration withAnimation:(void(^)(UIView *container))animation;
- (void)yj_dismissInDuration:(NSTimeInterval)duration withAnimation:(void(^)(UIView *container))animation;

@end
