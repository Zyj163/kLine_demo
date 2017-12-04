//
//  YJCustomAnimatedTransition.m
//  YJCustomModalController
//
//  Created by zhangyongjun on 16/2/11.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "YJCustomAnimatedTransition.h"
#import "UIView+YJTransitionAnimation.h"

@interface YJCustomAnimatedTransition ()


@end

@implementation YJCustomAnimatedTransition

- (instancetype)init {
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (NSTimeInterval)transitionDuration:(id)transitionContext {
    return self.holder.duration;
}

- (void)animateTransition:(id)transitionContext {
    
    UIView *toView = [[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey] view];
    UIView *fromView = [[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey] view];
    
    switch (self.holder.type) {
        case YJTransAnimationTypeSystemAlpha:
        {
            [UIView yj_gotoNext:self.holder.presented TransitionBySysAlphaFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case YJTransAnimationTypeAlpha:
        {
            [UIView yj_gotoNext:self.holder.presented TransitionByAlphaFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case YJTransAnimationTypeRotateX:
        {
            [UIView yj_gotoNext:self.holder.presented RotateXFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
                
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case YJTransAnimationTypeRotateY:
        {
            [UIView yj_gotoNext:self.holder.presented RotateYFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
                
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case YJTransAnimationTypeCure:
        {
            [UIView yj_gotoNext:self.holder.presented CureFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
                
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case YJTransAnimationTypeSameToNav:
        {
            [UIView yj_gotoNext:self.holder.presented SameToNavTransitionFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
                
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case YJTransAnimationTypeSize:
        {
            [UIView yj_gotoNext:self.holder.presented SizeTransitionFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
                
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case YJTransAnimationTypeMaskCircle:
        {
            [UIView yj_gotoNext:self.holder.presented transitionByMaskShapeFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
                [transitionContext completeTransition:YES];
            }];
        }
            break;
        case YJTransAnimationTypeCustom:
        {
            if (self.holder.animation) {
                self.holder.animation(self.holder.presented, fromView, toView);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.holder.duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [transitionContext completeTransition:YES];
                });
            }
        }
            break;
		case YJTransAnimationTypeSizeToSize:
		{
			[UIView yj_gotoNext:self.holder.presented sizeToSizeFromView:fromView toView:toView inDuration:self.holder.duration andComplete:^{
				[transitionContext completeTransition:YES];
			}];
		}
		default:
			break;
    }
}

@end
