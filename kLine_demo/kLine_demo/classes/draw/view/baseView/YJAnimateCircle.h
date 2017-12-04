//
//  YJAnimateCircle.h
//  KLine
//
//  Created by 张永俊 on 2017/10/9.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJAnimateCircle : UIView

@property (nonatomic, strong) UIColor *fillColor;
@property (nonatomic, assign, readonly) BOOL animating;
@property (nonatomic, assign) BOOL hiddenWhenStop;

- (void)startAnimate;
- (void)stopAnimate;

@end
