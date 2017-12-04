//
//  YJTab.m
//  myJsApp
//
//  Created by 张永俊 on 2017/11/16.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "YJTab.h"

@interface YJTab()

@property (nonatomic, copy) NSArray<NSString *> *titles;

@property (nonatomic, strong) NSMutableArray<ClickOnHandler> *clickOns;

@property (nonatomic, strong) NSMutableArray<UIButton *> *btns;

@property (nonatomic, assign) NSInteger preSelectedIdx;

@end

@implementation YJTab

- (instancetype)init
{
    self = [super init];
    if (self) {
        _specifyPaddingH = 0;
    }
    return self;
}

- (NSMutableArray<UIButton *> *)btns
{
    if (!_btns) {
        _btns = [NSMutableArray array];
    }
    return _btns;
}

- (NSMutableArray<ClickOnHandler> *)clickOns
{
    if (!_clickOns) {
        _clickOns = [NSMutableArray array];
    }
    return _clickOns;
}

- (void)setupWithTitles:(NSArray<NSString *> *)titles
{
    self.titles = titles;
}

- (void)addClickOnHandler:(void (^)(NSInteger, NSInteger))clickOn
{
    if (clickOn) [self.clickOns addObject:clickOn];
}

- (void)setTitles:(NSArray<NSString *> *)titles
{
    _titles = [titles copy];
    
    [_btns makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_btns removeAllObjects];
    
    [titles enumerateObjectsUsingBlock:^(NSString * _Nonnull title, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *btn = [UIButton new];
        [btn setTitle:title forState:UIControlStateNormal];
        [btn setTitleColor:self.normalTitleColor forState:UIControlStateNormal];
        [btn setTitleColor:self.selectedTitleColor forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(clickOnBtn:) forControlEvents:UIControlEventTouchUpInside];
        btn.titleLabel.font = self.titleFont;
        btn.tag = 100 + idx;
        [self.btns addObject:btn];
        [self addSubview:btn];
        
        if (self.specifyPaddingH) {
            [btn sizeToFit];
            btn.bounds = CGRectMake(0, 0, btn.bounds.size.width + self.specifyPaddingH * 2, btn.bounds.size.height);
        }
    }];
}

- (void)setSelected:(NSInteger)idx
{
    UIButton *btn = [self.btns objectAtIndex:idx];
    if (!btn) return;
    [self clickOnBtn:btn];
}

- (void)clickOnBtn:(UIButton *)sender
{
    if (sender.selected) return;
    
    NSInteger i = sender.tag - 100;
    self.btns[self.preSelectedIdx].selected = NO;
    sender.selected = YES;
    
    if (self.clickOns) {
        [self.clickOns enumerateObjectsUsingBlock:^(ClickOnHandler  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj(self.preSelectedIdx, i);
        }];
    }
    
    self.preSelectedIdx = i;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (_btns.count == 0) return;
    CGFloat w = self.specifyPaddingH ? _btns[0].bounds.size.width :( CGRectGetWidth(self.bounds) / _btns.count);
    CGFloat space = (CGRectGetWidth(self.bounds)- w * _btns.count) / (_btns.count - 1);
    CGFloat y = 0;
    CGFloat h = CGRectGetHeight(self.bounds);
    [_btns enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = (w + space) * idx;
        [obj setFrame:(CGRect){x, y, w, h}];
    }];
}

@end
