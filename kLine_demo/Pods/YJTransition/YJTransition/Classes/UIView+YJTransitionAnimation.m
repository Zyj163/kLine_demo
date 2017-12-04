//
//  UIView+YJTransitionAnimation.m
//  YJCustomModalController
//
//  Created by zhangyongjun on 16/2/12.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "UIView+YJTransitionAnimation.h"
#import <objc/runtime.h>

@implementation UIView (YJTransitionAnimation)
//左右
+ (void)yj_gotoNext:(BOOL)gotoNext SameToNavTransitionFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
    if (gotoNext) {
		CGRect frame = toView.frame;
		frame.origin.x = frame.size.width;
		toView.frame = frame;
        [UIView animateWithDuration:duration animations:^{
			CGRect frame = toView.frame;
			frame.origin.x = 0;
			toView.frame = frame;
        } completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }else {
		CGRect frame = toView.frame;
		frame.origin.x = 0;
		toView.frame = frame;
        [UIView animateWithDuration:duration animations:^{
			CGRect frame = toView.frame;
			frame.origin.x = frame.size.width;
			toView.frame = frame;
        } completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }
}

//大小
+ (void)yj_gotoNext:(BOOL)gotoNext SizeTransitionFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
    if (gotoNext) {
        toView.transform = CGAffineTransformMakeScale(0.05, 0.05);
        [UIView animateWithDuration:duration animations:^{
            toView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }else {
        [UIView animateWithDuration:duration animations:^{
            fromView.transform = CGAffineTransformMakeScale(0.05, 0.05);
        } completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }
}

//y旋转
+ (void)yj_gotoNext:(BOOL)gotoNext RotateYFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
    if (gotoNext) {
        [UIView transitionFromView:fromView toView:toView duration:duration options:UIViewAnimationOptionTransitionFlipFromRight completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }else {
        [UIView transitionFromView:fromView toView:toView duration:duration options:UIViewAnimationOptionTransitionFlipFromLeft completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }
    
#pragma mark - 有问题！！！
//    UIViewAnimationTransition transition;
//    
//    if (gotoNext) {
//        transition = UIViewAnimationTransitionFlipFromRight;
//    }else {
//        transition = UIViewAnimationTransitionFlipFromLeft;
//    }
//    
//    CGContextRef context = UIGraphicsGetCurrentContext(); //返回当前视图堆栈顶部的图形上下文
//    [UIView beginAnimations:nil context:context];
//    
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIView setAnimationDuration:duration];
//    [fromView.window exchangeSubviewAtIndex:0 withSubviewAtIndex:1];
//    [UIView setAnimationTransition:transition forView:fromView.window cache:NO];
//    
//    [UIView commitAnimations];
}

//x旋转
+ (void)yj_gotoNext:(BOOL)gotoNext RotateXFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
    if (gotoNext) {
        [UIView transitionFromView:fromView toView:toView duration:duration options:UIViewAnimationOptionTransitionFlipFromTop completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }else {
        [UIView transitionFromView:fromView toView:toView duration:duration options:UIViewAnimationOptionTransitionFlipFromBottom completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }
}

//翻页
+ (void)yj_gotoNext:(BOOL)gotoNext CureFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
    if (gotoNext) {
        [UIView transitionFromView:fromView toView:toView duration:duration options:UIViewAnimationOptionTransitionCurlUp completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }else {
        [UIView transitionFromView:fromView toView:toView duration:duration options:UIViewAnimationOptionTransitionCurlDown completion:^(BOOL finished) {
            if (finished) {
                if (complete) {
                    complete();
                }
            }
        }];
    }
}

//渐变
+ (void)yj_gotoNext:(BOOL)gotoNext TransitionByAlphaFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
    fromView.alpha = 1.;
    toView.alpha = 0.;
    [UIView animateWithDuration:duration animations:^{
        fromView.alpha = 0.;
        toView.alpha = 1.;
    } completion:^(BOOL finished) {
        if (finished) {
            if (complete) {
                complete();
            }
        }
    }];
}

+ (void)yj_gotoNext:(BOOL)gotoNext TransitionBySysAlphaFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
    [UIView transitionFromView:fromView toView:toView duration:duration options:UIViewAnimationOptionTransitionCrossDissolve completion:^(BOOL finished) {
        if (finished) {
            if (complete) {
                complete();
            }
        }
    }];
}

//遮罩
+ (void)yj_gotoNext:(BOOL)gotoNext transitionByMaskShapeFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
    UIBezierPath *fromPath;
    UIBezierPath *toPath;
    __block CAShapeLayer *maskLayer = [CAShapeLayer layer];
    UIView *animationView;
    CGFloat radius = 0;
    if (gotoNext) {
        fromPath = [UIBezierPath bezierPathWithArcCenter:fromView.yj_maskCenter radius:1 startAngle:0 endAngle:M_PI * 2 clockwise:NO];
        CGFloat w = toView.yj_maskCenter.x > toView.bounds.size.width/2 ? toView.yj_maskCenter.x : (toView.bounds.size.width - toView.yj_maskCenter.x);
        CGFloat h = toView.yj_maskCenter.y > toView.bounds.size.height/2 ? toView.yj_maskCenter.y : (toView.bounds.size.height - toView.yj_maskCenter.y);
        radius = sqrtf(powf(w, 2) + powf(h, 2));
        toPath = [UIBezierPath bezierPathWithArcCenter:toView.yj_maskCenter radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
        animationView = toView;
    }else {
        toPath = [UIBezierPath bezierPathWithArcCenter:toView.yj_maskCenter radius:1 startAngle:0 endAngle:M_PI * 2 clockwise:NO];
        
        CGFloat w = fromView.yj_maskCenter.x > fromView.bounds.size.width/2 ? fromView.yj_maskCenter.x : (fromView.bounds.size.width - fromView.yj_maskCenter.x);
        CGFloat h = fromView.yj_maskCenter.y > fromView.bounds.size.height/2 ? fromView.yj_maskCenter.y : (fromView.bounds.size.height - fromView.yj_maskCenter.y);
        radius = sqrtf(powf(w, 2) + powf(h, 2));
        fromPath = [UIBezierPath bezierPathWithArcCenter:fromView.yj_maskCenter radius:radius startAngle:0 endAngle:M_PI * 2 clockwise:NO];
        animationView = fromView;
    }

    maskLayer.path = fromPath.CGPath;
    animationView.layer.mask = maskLayer;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (id)fromPath.CGPath;
    animation.toValue = (id)toPath.CGPath;
    animation.fillMode = kCAFillModeForwards;
    animation.removedOnCompletion = NO;
    animation.duration = duration;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    [animationView.layer.mask addAnimation:animation forKey:nil];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (complete) {
            complete();
        }
        [animationView.layer.mask removeFromSuperlayer];
        animationView.layer.mask = nil;
    });
}

+ (void)yj_gotoNext:(BOOL)gotoNext sizeToSizeFromView:(UIView *)fromView toView:(UIView *)toView inDuration:(NSTimeInterval)duration andComplete:(void (^)())complete
{
	if (gotoNext) {
		UIColor *color = toView.backgroundColor;
		toView.transform = CGAffineTransformMakeScale(toView.yj_maskSize.width / toView.bounds.size.width, toView.yj_maskSize.height / toView.bounds.size.height);
		toView.layer.position = toView.yj_maskCenter;
		toView.backgroundColor = [UIColor clearColor];
		[UIView animateWithDuration:duration animations:^{
			toView.transform = CGAffineTransformIdentity;
			toView.layer.position = CGPointMake([UIScreen mainScreen].bounds.size.width/2, [UIScreen mainScreen].bounds.size.height/2);
			toView.backgroundColor = color;
		} completion:^(BOOL finished) {
			if (finished) {
				if (complete) {
					complete();
				}
			}
		}];
	}else {
		[UIView animateWithDuration:duration animations:^{
			fromView.transform = CGAffineTransformMakeScale(fromView.yj_maskSize.width / fromView.bounds.size.width, fromView.yj_maskSize.height / fromView.bounds.size.height);
			fromView.layer.position = fromView.yj_maskCenter;
			fromView.backgroundColor = [UIColor clearColor];
		} completion:^(BOOL finished) {
			if (finished) {
				if (complete) {
					complete();
				}
			}
		}];
	}
}


- (void)setYj_maskCenter:(CGPoint)yj_maskCenter
{
    [self willChangeValueForKey:@"yj_maskCenter"];
    NSValue *value = [NSValue valueWithCGPoint:yj_maskCenter];
    objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [self didChangeValueForKey:@"yj_maskCenter"];
}

- (CGPoint)yj_maskCenter
{
    NSValue *value = objc_getAssociatedObject(self, @selector(setYj_maskCenter:));
    if (value == nil) {
        value = [NSValue valueWithCGPoint:self.center];
    }
    return [value CGPointValue];
}

- (void)setYj_maskSize:(CGSize)yj_maskSize
{
	[self willChangeValueForKey:@"yj_maskSize"];
	NSValue *value = [NSValue valueWithCGSize:yj_maskSize];
	objc_setAssociatedObject(self, _cmd, value, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	[self didChangeValueForKey:@"yj_maskSize"];
}

- (CGSize)yj_maskSize
{
	NSValue *value = objc_getAssociatedObject(self, @selector(setYj_maskSize:));
	if (value == nil) {
		value = [NSValue valueWithCGSize:CGSizeZero];
	}
	return [value CGSizeValue];
}

@end










