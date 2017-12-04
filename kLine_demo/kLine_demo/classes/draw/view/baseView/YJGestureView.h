//
//  YJGestureView.h
//  KLine
//
//  Created by 张永俊 on 2017/9/27.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJIndicatorWindow.h"
@class YJGestureView;

typedef NS_OPTIONS(NSUInteger, YJGestureViewRefreshState) {
  YJGestureViewRefreshStateNone = 1 << 0,
  YJGestureViewRefreshStateLeftRefreshing = 1 << 1,
  YJGestureViewRefreshStateRightRefreshing = 1 << 2
};

@protocol YJGestureViewDelegate<NSObject>

@optional
- (void)gestureView:(YJGestureView *)gestureView didTapOn:(CGPoint)point;
@optional
- (void)gestureView:(YJGestureView *)gestureView didLongPressOn:(CGPoint)point;
@optional
- (BOOL)gestureView:(YJGestureView *)gestureView shouldResetDisWithMoving:(CGFloat)distance;
@optional
- (BOOL)gestureView:(YJGestureView *)gestureView shouldResetScale:(CGFloat)scale centerPoint:(CGPoint)centerPoint;

@optional
- (void)gestureView:(YJGestureView *)gestureView gestureStateChanged:(UIGestureRecognizer *)gesture;

@optional
- (void)gestureViewBeganLeftRefreshing:(YJGestureView *)gestureView;
@optional
- (void)gestureViewBeganRightRefreshing:(YJGestureView *)gestureView;

@optional
- (void)gestureView:(YJGestureView *)gestureView vindicatorLocationChanged:(CGFloat)location;

@optional
- (UIView *)gestureViewCustomLeftRefreshView:(YJGestureView *)gestureView;
@optional
- (UIView *)gestureViewCustomRightRefreshView:(YJGestureView *)gestureView;

@end

@interface YJGestureView : UIView

@property (nonatomic, weak) id<YJGestureViewDelegate> delegate;

@property (nonatomic, strong, readonly) UIView *scrollView;
@property (nonatomic, assign) BOOL enablePinchGes;
@property (nonatomic, assign) BOOL enableTapGes;
@property (nonatomic, assign) BOOL enableLongPressGes;
@property (nonatomic, assign) BOOL enablePanGes;

@property (nonatomic, assign, readonly) CGFloat currentXVelocity;

/**===============十字指示器==================*/
@property (nonatomic, strong, readonly) YJIndicatorWindow *indicatorWindow;
@property (nonatomic, assign, readonly) BOOL indicatorIsShown;

- (void)showIndicatorAtLocation:(CGFloat)location;
- (void)hideIndicator;

- (void)fixHIndicatorLocation:(CGFloat)hLocation withHText:(NSString *)hText vIndicatorLocation:(CGFloat)vLocation centerY:(CGFloat)centerY withVText:(NSString *)vText;
/**=================================*/


/**===============刷新&加载==================*/
@property (nonatomic, assign) BOOL hasLeftRefreshView;
@property (nonatomic, assign) BOOL hasRightRefreshView;

@property (nonatomic, strong, readonly) UIView *leftRefreshView;
@property (nonatomic, strong, readonly) UIView *rightRefreshView;

@property (nonatomic, assign, readonly) YJGestureViewRefreshState refreshState;

- (void)startDragOnLeftEdge;
- (void)endDragOnLeftEdge;

- (void)startDragOnRightEdge;
- (void)endDragOnRightEdge;

- (void)beginLeftRefreshing;
- (void)endLeftRefreshing;

- (void)beginRightRefreshing;
- (void)endRightRefreshing;
/**=================================*/


/**================loading=================*/
- (void)showHUD;
- (void)hideHUD;
/**=================================*/

@end



