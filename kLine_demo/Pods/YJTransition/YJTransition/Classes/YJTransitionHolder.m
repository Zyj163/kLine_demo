//
//  YJTransitionHolder.m
//  YJCustomModalController
//
//  Created by zhangyongjun on 16/4/12.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "YJTransitionHolder.h"

@implementation YJTransitionHolder

- (void)dealloc
{
    _animation = nil;
}

+ (NSArray *)sysTypes
{
    return @[@(YJTransAnimationTypeRotateY), @(YJTransAnimationTypeRotateX), @(YJTransAnimationTypeCure), @(YJTransAnimationTypeSystemAlpha)];
}

+ (NSArray *)customTypes
{
    return @[@(YJTransAnimationTypeAlpha), @(YJTransAnimationTypeSameToNav), @(YJTransAnimationTypeSize), @(YJTransAnimationTypeMaskCircle), @(YJTransAnimationTypeCustom), @(YJTransAnimationTypeSizeToSize)];
}

+ (BOOL)changeType:(YJTransAnimationType)type toType:(YJTransAnimationType)toType
{
    NSArray *sysArr = [self sysTypes];
    NSArray *customArr = [self customTypes];
    if (([sysArr containsObject:@(type)] && [sysArr containsObject:@(toType)]) || ([customArr containsObject:@(type)] && [customArr containsObject:@(toType)])) {
        return YES;
    }else {
        return NO;
    }
}

@end
