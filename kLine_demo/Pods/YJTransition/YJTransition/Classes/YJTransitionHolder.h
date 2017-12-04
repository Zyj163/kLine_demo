//
//  TransitionHolder.h
//  CustomModalController
//
//  Created by zhangyongjun on 16/4/12.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, YJTransAnimationType) {
    YJTransAnimationTypeNone = 0,
//以下四种可混用（present和dismiss可以不一样）
    YJTransAnimationTypeRotateY,
    YJTransAnimationTypeRotateX,
    YJTransAnimationTypeCure,
    YJTransAnimationTypeSystemAlpha,
    
//以下五种可混用（present和dismiss可以不一样）
    YJTransAnimationTypeAlpha,
    YJTransAnimationTypeSameToNav,
    YJTransAnimationTypeSize,
    YJTransAnimationTypeMaskCircle,
    YJTransAnimationTypeCustom,
	
	YJTransAnimationTypeSizeToSize
};


@interface YJTransitionHolder : NSObject

@property (assign, nonatomic) BOOL presented;
@property (assign, nonatomic) CGFloat duration;
@property (assign, nonatomic) YJTransAnimationType type;
@property (assign, nonatomic) CGPoint maskCenter;

@property (copy, nonatomic) void(^animation)(BOOL gotoNext, UIView *fromView, UIView *toView);

+ (BOOL)changeType:(YJTransAnimationType)type toType:(YJTransAnimationType)toType;

@end
