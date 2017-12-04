//
//  YJCustomAnimatedTransition.h
//  YJCustomModalController
//
//  Created by zhangyongjun on 16/2/11.
//  Copyright © 2016年 张永俊. All rights reserved.
//

#import "YJTransitionHolder.h"

@interface YJCustomAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (strong, nonatomic) YJTransitionHolder *holder;

@end
