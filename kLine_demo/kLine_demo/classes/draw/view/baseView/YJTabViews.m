//
//  YJTabViews.m
//  myJsApp
//
//  Created by 张永俊 on 2017/11/16.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "YJTabViews.h"
#import "YJTab.h"

@interface YJTabViewsContainerView: UIView

@property (nonatomic, assign) UIEdgeInsets specifyContentsInset;

@end

@implementation YJTabViewsContainerView

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(self.specifyContentsInset.left, self.specifyContentsInset.top, CGRectGetWidth(self.bounds)-self.specifyContentsInset.left-self.specifyContentsInset.right, CGRectGetHeight(self.bounds)-self.specifyContentsInset.top-self.specifyContentsInset.bottom);
    }];
}

@end

@interface YJTabViews()

@property (nonatomic, strong) YJTabViewsContainerView *containerView;

@property (nonatomic, strong) YJTab *tab;

@property (nonatomic, assign) YJTabViewsTabPosition tabPosition;

@property (nonatomic, assign) CGFloat tabH;

@end

@implementation YJTabViews

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    YJTabViewsContainerView *containerView = [YJTabViewsContainerView new];
    _containerView = containerView;
    [self addSubview:containerView];
    self.specifyContentsInset = UIEdgeInsetsZero;
}

- (void)setSpecifyContentsInset:(UIEdgeInsets)specifyContentsInset
{
    _specifyContentsInset = specifyContentsInset;
    
    self.containerView.specifyContentsInset = specifyContentsInset;
}

- (void)installTab:(YJTab *)tab withTitles:(NSArray<NSString *> *)titles tabH:(CGFloat)tabH position:(YJTabViewsTabPosition)position contents:(UIView *(^)(NSInteger, NSInteger))contents
{
    [self.tab removeFromSuperview];
    self.tab = tab;
    self.tabPosition = position;
    self.tabH = tabH;
    
    [self addSubview:tab];
    
    __weak typeof(self) ws = self;
    [tab addClickOnHandler:^(NSInteger preIdx, NSInteger idx) {
        [ws.containerView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        UIView *content = contents(preIdx, idx);
        content.frame = ws.containerView.bounds;
        [ws.containerView addSubview:content];
    }];
    
    [tab setupWithTitles:titles];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat y = 0;
    CGFloat h = CGRectGetHeight(self.bounds);
    if (self.tab) {
        switch (self.tabPosition) {
            case YJTabViewsTabPositionTop:
                self.tab.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), self.tabH);
                y = self.tabH;
                h -= self.tabH;
                break;
            case YJTabViewsTabPositionBottom:
                self.tab.frame = CGRectMake(0, CGRectGetHeight(self.bounds)-self.tabH, CGRectGetWidth(self.bounds), self.tabH);
                h -= self.tabH;
                break;
            default:
                break;
        }
    }
    
    self.containerView.frame = CGRectMake(0, y, CGRectGetWidth(self.bounds), h);
}

@end







