//
//  YJIndicatorWindow.h
//  myJsApp
//
//  Created by 张永俊 on 2017/11/23.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJIndicatorWindow : UIView

@property (nonatomic, assign) UIEdgeInsets indicatorInset;
@property (nonatomic, assign) CGFloat labelPaddingHorizontal;
@property (nonatomic, assign) CGFloat labelHeight;


@property (nonatomic, strong, readonly) UIView *vIndicator;
@property (nonatomic, strong, readonly) UIView *hIndicator;
@property (nonatomic, strong, readonly) UILabel *hIndicatorLabel;
@property (nonatomic, strong, readonly) UILabel *vIndicatorLabel;


- (void)fixHIndicatorLocation:(CGFloat)hLocation withHText:(NSString *)hText vIndicatorLocation:(CGFloat)vLocation centerY:(CGFloat)centerY withVText:(NSString *)vText;

@end
