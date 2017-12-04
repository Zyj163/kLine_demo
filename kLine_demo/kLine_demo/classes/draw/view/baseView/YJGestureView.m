//
//  YJGestureView.m
//  KLine
//
//  Created by 张永俊 on 2017/9/27.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJGestureView.h"

@interface YJGestureView() <UIGestureRecognizerDelegate>

{
    struct {
        unsigned int knowTap : 1;
        unsigned int knowPinch : 1;
        unsigned int knowPan : 1;
        unsigned int knowLongPress : 1;
        unsigned int knowState: 1;
        unsigned int knowLeftBeganRefreshing: 1;
        unsigned int knowRightBeganRefreshing: 1;
        unsigned int knowVIndicator: 1;
        unsigned int knowCustomLeftRefreshView: 1;
        unsigned int knowCustomRightRefreshView: 1;
    } _delegates;
}

@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGes;
@property (nonatomic, strong) UITapGestureRecognizer *tapGes;
@property (nonatomic, strong) UIPanGestureRecognizer *panGes;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGes;

@property (nonatomic, assign) CGFloat pinchStartDis;
@property (nonatomic, assign) CGPoint pinchCenter;

@property (nonatomic, strong) UIView *scrollView;

@property (nonatomic, assign) BOOL dragOnLeftEdge;
@property (nonatomic, assign) BOOL dragOnRightEdge;

@property (nonatomic, assign) YJGestureViewRefreshState refreshState;

@property (nonatomic, strong) UIView *leftRefreshView;
@property (nonatomic, strong) UIView *rightRefreshView;

@property (nonatomic, strong) YJIndicatorWindow *indicatorWindow;

@property (nonatomic, assign) BOOL indicatorIsShown;

@property (nonatomic, assign) CGFloat currentXVelocity;
@property (nonatomic, assign) CGFloat dump;

@property (nonatomic, strong) UIView *HUDView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;

@end

@implementation YJGestureView

- (void)setDelegate:(id<YJGestureViewDelegate>)delegate
{
    _delegate = delegate;
    _delegates.knowTap = [delegate respondsToSelector:@selector(gestureView:didTapOn:)];
    _delegates.knowPinch = [delegate respondsToSelector:@selector(gestureView:shouldResetScale:centerPoint:)];
    _delegates.knowPan = [delegate respondsToSelector:@selector(gestureView:shouldResetDisWithMoving:)];
    _delegates.knowLongPress = [delegate respondsToSelector:@selector(gestureView:didLongPressOn:)];
    _delegates.knowState = [delegate respondsToSelector:@selector(gestureView:gestureStateChanged:)];
    _delegates.knowLeftBeganRefreshing = [delegate respondsToSelector:@selector(gestureViewBeganLeftRefreshing:)];
    _delegates.knowRightBeganRefreshing = [delegate respondsToSelector:@selector(gestureViewBeganRightRefreshing:)];
    _delegates.knowVIndicator = [delegate respondsToSelector:@selector(gestureView:vindicatorLocationChanged:)];
    _delegates.knowCustomLeftRefreshView = [delegate respondsToSelector:@selector(gestureViewCustomLeftRefreshView:)];
    _delegates.knowCustomRightRefreshView = [delegate respondsToSelector:@selector(gestureViewCustomRightRefreshView:)];
}

- (UIPinchGestureRecognizer *)pinchGes
{
    if (!_pinchGes) {
        _pinchGes = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchOn:)];
        [self addGestureRecognizer:_pinchGes];
    }
    return _pinchGes;
}

- (UITapGestureRecognizer *)tapGes
{
    if (!_tapGes) {
        _tapGes = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOn:)];
        [self addGestureRecognizer:_tapGes];
    }
    return _tapGes;
}

- (UIPanGestureRecognizer *)panGes
{
    if (!_panGes) {
        _panGes = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOn:)];
        [self addGestureRecognizer:_panGes];
        _panGes.maximumNumberOfTouches = 1;
        _panGes.delegate = self;
    }
    return _panGes;
}

- (UILongPressGestureRecognizer *)longPressGes
{
    if (!_longPressGes) {
        _longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressOn:)];
        [self addGestureRecognizer:_longPressGes];
        _longPressGes.minimumPressDuration = 1;
    }
    return _longPressGes;
}

- (UIView *)HUDView
{
    if (!_HUDView) {
        _HUDView = [UIView new];
        _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityView.layer.anchorPoint = CGPointMake(0.5, 0.5);
        [_HUDView addSubview:_activityView];
    }
    return _HUDView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    self.dump = 0.5;
    _hasLeftRefreshView = YES;
    _hasRightRefreshView = YES;
    _enablePanGes = YES;
    _enableTapGes = YES;
    _enablePinchGes = YES;
    _enableLongPressGes = YES;
    
    self.clipsToBounds = YES;
    
    self.scrollView = [UIView new];
    [self addSubview:self.scrollView];
    
    self.backgroundColor = [UIColor whiteColor];
    
    [self pinchGes];
    [self panGes];
    [self longPressGes];
    [self tapGes];
}

- (UIView *)leftRefreshView
{
    if (!_leftRefreshView) {
        if (_delegates.knowCustomLeftRefreshView) {
            _leftRefreshView = [self.delegate gestureViewCustomLeftRefreshView:self];
        } else {
            _leftRefreshView = [UIView new];
            _leftRefreshView.backgroundColor = [UIColor redColor];
            _leftRefreshView.layer.bounds = CGRectMake(0, 0, 30, 44);
        }
        [self insertSubview:_leftRefreshView atIndex:0];
        _leftRefreshView.layer.anchorPoint = CGPointMake(0, 0.5);
    }
    return _leftRefreshView;
}

- (UIView *)rightRefreshView
{
    if (!_rightRefreshView) {
        if (_delegates.knowCustomRightRefreshView) {
            _rightRefreshView = [self.delegate gestureViewCustomRightRefreshView:self];
        } else {
            _rightRefreshView = [UIView new];
            _rightRefreshView.backgroundColor = [UIColor redColor];
            _rightRefreshView.layer.bounds = CGRectMake(0, 0, 30, 44);
        }
        [self insertSubview:_rightRefreshView atIndex:0];
        _rightRefreshView.layer.anchorPoint = CGPointMake(1, 0.5);
    }
    return _rightRefreshView;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.scrollView.backgroundColor = backgroundColor;
}

- (void)setHasLeftRefreshView:(BOOL)hasLeftRefreshView
{
    _hasLeftRefreshView = hasLeftRefreshView;
    
    self.leftRefreshView.hidden = !hasLeftRefreshView;
}

- (void)setHasRightRefreshView:(BOOL)hasRightRefreshView
{
    _hasRightRefreshView = hasRightRefreshView;
    
    self.rightRefreshView.hidden = !hasRightRefreshView;
}

- (void)setEnablePanGes:(BOOL)enablePanGes
{
    _enablePanGes = enablePanGes;
    
    self.panGes.enabled = enablePanGes;
}

- (void)setEnableTapGes:(BOOL)enableTapGes
{
    _enableTapGes = enableTapGes;
    
    self.tapGes.enabled = enableTapGes;
}

- (void)setEnablePinchGes:(BOOL)enablePinchGes
{
    _enablePinchGes = enablePinchGes;
    
    self.pinchGes.enabled = enablePinchGes;
}

- (void)setEnableLongPressGes:(BOOL)enableLongPressGes
{
    _enableLongPressGes = enableLongPressGes;
    
    self.longPressGes.enabled = enableLongPressGes;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;
    
    _leftRefreshView.layer.position = CGPointMake(0, CGRectGetHeight(self.frame)/2);
    _rightRefreshView.layer.position = CGPointMake(CGRectGetWidth(self.bounds), CGRectGetHeight(self.frame)/2);
    _indicatorWindow.frame = self.bounds;
    
    _HUDView.frame = self.bounds;
    _activityView.layer.position = CGPointMake(CGRectGetMidX(_HUDView.frame), CGRectGetMidY(_HUDView.frame));
}

- (void)startDragOnRightEdge
{
    self.dragOnRightEdge = YES;
}

- (void)startDragOnLeftEdge
{
    self.dragOnLeftEdge = YES;
}

- (void)endDragOnRightEdge
{
    self.dragOnRightEdge = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.frame = self.bounds;
    }];
}

- (void)endDragOnLeftEdge
{
    self.dragOnLeftEdge = NO;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.frame = self.bounds;
    }];
}

- (void)endLeftRefreshing
{
    self.refreshState &= ~YJGestureViewRefreshStateLeftRefreshing;
    [self endDragOnLeftEdge];
}

- (void)beginLeftRefreshing
{
    if (_delegates.knowLeftBeganRefreshing && !(self.refreshState & YJGestureViewRefreshStateLeftRefreshing)) {
        self.refreshState |= YJGestureViewRefreshStateLeftRefreshing;
        [self.delegate gestureViewBeganLeftRefreshing:self];
    }
    if (!self.hasLeftRefreshView) return;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.frame = CGRectOffset(self.bounds, CGRectGetWidth(self.leftRefreshView.frame), 0);
    }];
}

- (void)endRightRefreshing
{
    self.refreshState &= ~YJGestureViewRefreshStateRightRefreshing;
    [self endDragOnRightEdge];
}

- (void)beginRightRefreshing
{
    if (_delegates.knowRightBeganRefreshing && !(self.refreshState & YJGestureViewRefreshStateRightRefreshing)) {
        self.refreshState |= YJGestureViewRefreshStateRightRefreshing;
        [self.delegate gestureViewBeganRightRefreshing:self];
    }
    if (!self.hasRightRefreshView) return;
    [UIView animateWithDuration:0.25 animations:^{
        self.scrollView.frame = CGRectOffset(self.bounds, -CGRectGetWidth(self.rightRefreshView.frame), 0);
    }];
}

- (void)pinchOn:(UIPinchGestureRecognizer *)ges
{
    if (ges.numberOfTouches != 2) return;
    
    CGPoint p0 = [ges locationOfTouch:0 inView:ges.view];
    CGPoint p1 = [ges locationOfTouch:1 inView:ges.view];
    CGFloat scale = 1;
    switch (ges.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.pinchStartDis = ABS(p1.x - p0.x);
            self.pinchCenter = CGPointMake(MIN(p0.x, p1.x) + ABS(p0.x - p1.x)/2, MIN(p0.y, p1.y) + ABS(p0.y - p1.y)/2);
            
            if (_delegates.knowState)
                [self.delegate gestureView:self gestureStateChanged:ges];
            return;
        }
        case UIGestureRecognizerStateEnded:
        {
            if (_delegates.knowState)
                [self.delegate gestureView:self gestureStateChanged:ges];
            return;
        }
        default:
        {
            CGFloat currentDis = ABS(p1.x - p0.x);
            scale = currentDis / self.pinchStartDis;
            
            if (_delegates.knowState)
                [self.delegate gestureView:self gestureStateChanged:ges];
            break;
        }
    }
    
    if (_delegates.knowPinch)
        if ([self.delegate gestureView:self shouldResetScale:scale centerPoint:self.pinchCenter]) {
            self.pinchStartDis = ABS(p1.x - p0.x);
            self.pinchCenter = CGPointMake(MIN(p0.x, p1.x) + ABS(p0.x - p1.x)/2, MIN(p0.y, p1.y) + ABS(p0.y - p1.y)/2);
        }
}

- (void)tapOn:(UITapGestureRecognizer *)ges
{
    if (_delegates.knowTap)
        [self.delegate gestureView:self didTapOn:[ges locationInView:ges.view]];
    if (_delegates.knowState)
        [self.delegate gestureView:self gestureStateChanged:ges];
    
}

- (void)panOn:(UIPanGestureRecognizer *)ges
{
    if (ges.numberOfTouches > 1) return;
    
    [self dealWithPan:ges translation:[ges translationInView:ges.view].x];
    
    if (ges.state == UIGestureRecognizerStateBegan) {
        self.currentXVelocity = 0;
    }
    if (ges.state == UIGestureRecognizerStateEnded && !self.dragOnRightEdge && !self.dragOnLeftEdge) {
        self.currentXVelocity = [ges velocityInView:ges.view].x;
        if (ABS(self.currentXVelocity) > 5) {
            CADisplayLink *link = [CADisplayLink displayLinkWithTarget:self selector:@selector(followVelocity:)];
            [link addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        }
    }
}

- (void)followVelocity:(CADisplayLink *)link
{
    self.currentXVelocity *= 0.97;
    if (ABS(self.currentXVelocity/60.) < 1) {
        [link invalidate];
        self.currentXVelocity = 0;
    }
    [self dealWithPan:self.panGes translation:self.currentXVelocity/60.];
}

- (void)dealWithPan:(UIPanGestureRecognizer *)ges translation:(CGFloat)translation
{
    if (self.dragOnLeftEdge) {
        [self leftRefreshView];
        CGRect frame = CGRectOffset(self.scrollView.frame, translation, 0);
        
        if ((ges.state == UIGestureRecognizerStatePossible || ges.state == UIGestureRecognizerStateEnded) && self.currentXVelocity < 100) {
            if (self.hasLeftRefreshView && frame.origin.x > CGRectGetWidth(self.leftRefreshView.frame)) {
                [self beginLeftRefreshing];
            } else {
                [self endDragOnLeftEdge];
            }
            return;
        }
        
        if (frame.origin.x <= 0) {
            [self endDragOnLeftEdge];
        } else {
            self.scrollView.frame = frame;
            [ges setTranslation:CGPointZero inView:ges.view];
            if (self.currentXVelocity > 100 && (frame.origin.x > CGRectGetWidth(self.leftRefreshView.frame) * 2)) {
                self.currentXVelocity = 0;
            }
            return;
        }
    }
    
    if (self.dragOnRightEdge) {
        [self rightRefreshView];
        CGRect frame = CGRectOffset(self.scrollView.frame, translation, 0);
        
        if ((ges.state == UIGestureRecognizerStatePossible || ges.state == UIGestureRecognizerStateEnded) && self.currentXVelocity > -100) {
            if (self.hasRightRefreshView && CGRectGetMaxX(frame) < CGRectGetMinX(self.rightRefreshView.frame)) {
                [self beginRightRefreshing];
            } else {
                [self endDragOnRightEdge];
            }
            return;
        }
        
        if (CGRectGetMaxX(frame) >= CGRectGetWidth(self.frame)) {
            [self endDragOnRightEdge];
        } else {
            self.scrollView.frame = frame;
            [ges setTranslation:CGPointZero inView:ges.view];
            if (self.currentXVelocity < -100 && (-frame.origin.x > CGRectGetWidth(self.leftRefreshView.frame) * 2)) {
                self.currentXVelocity = 0;
            }
            return;
        }
    }
    
    if (_delegates.knowPan) {
        if ([self.delegate gestureView:self shouldResetDisWithMoving:translation]) {
            [ges setTranslation:CGPointZero inView:ges.view];
        }
    }
    
    if (_delegates.knowState)
        [self.delegate gestureView:self gestureStateChanged:ges];
}

- (void)longPressOn:(UILongPressGestureRecognizer *)ges
{
    if (_delegates.knowLongPress)
        [self.delegate gestureView:self didLongPressOn:[ges locationInView:ges.view]];
    if (_delegates.knowState)
        [self.delegate gestureView:self gestureStateChanged:ges];
    
}

- (void)panOnIndicatorWindow:(UIPanGestureRecognizer *)ges
{
    if (ges.numberOfTouches > 1) {
        return;
    }
    
    CGPoint location = [ges locationInView:ges.view];
    [self showIndicatorAtLocation:location.x];
}

- (UIView *)indicatorWindow
{
    if (!_indicatorWindow) {
        _indicatorWindow = [[YJIndicatorWindow alloc] initWithFrame:self.bounds];
        
        [self addSubview:_indicatorWindow];
        
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panOnIndicatorWindow:)];
        [_indicatorWindow addGestureRecognizer:pan];
    }
    return _indicatorWindow;
}

- (void)showIndicatorAtLocation:(CGFloat)location
{
    if (!self.indicatorIsShown) {
        self.indicatorIsShown = YES;
        self.indicatorWindow.hidden = NO;
        [self bringSubviewToFront:self.indicatorWindow];
    }
    
    if (_delegates.knowVIndicator) {
        [self.delegate gestureView:self vindicatorLocationChanged:location];
    }
}

- (void)fixHIndicatorLocation:(CGFloat)hLocation withHText:(NSString *)hText vIndicatorLocation:(CGFloat)vLocation centerY:(CGFloat)centerY withVText:(NSString *)vText
{
    [_indicatorWindow fixHIndicatorLocation:hLocation withHText:hText vIndicatorLocation:vLocation centerY:centerY withVText:vText];
}

- (void)hideIndicator
{
    self.indicatorIsShown = NO;
    self.indicatorWindow.hidden = YES;
}

- (void)showHUD
{
    if (_HUDView.superview) return;
    
    [self addSubview:self.HUDView];
    [self.activityView startAnimating];
}

- (void)hideHUD
{
    [_HUDView removeFromSuperview];
}

@end
