#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIView+YJTransitionAnimation.h"
#import "UIViewController+YJTransition.h"
#import "YJCustomAnimatedTransition.h"
#import "YJCustomTransitioningDelegate.h"
#import "YJTransition.h"
#import "YJTransitionHolder.h"

FOUNDATION_EXPORT double YJTransitionVersionNumber;
FOUNDATION_EXPORT const unsigned char YJTransitionVersionString[];

