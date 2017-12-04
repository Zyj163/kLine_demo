//
//  StockTabView.m
//  myJsApp
//
//  Created by 张永俊 on 2017/10/11.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "StockTabView.h"
#import "YJHelper.h"

@interface StockTabDrawerViewCell: UIView

@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *valueLabel;

@end

@implementation StockTabDrawerViewCell

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
    YJHelper *helper = [YJHelper sharedHelper];
    
    _nameLabel = [UILabel new];
    _valueLabel = [UILabel new];
    
    _nameLabel.font = helper.fontE;
    _valueLabel.font = [UIFont fontWithName:@"DINAlternate-bold" size:13];
    _nameLabel.textColor = helper.color3;
    _valueLabel.textColor = helper.color1;
    
    
    [self addSubview:_nameLabel];
    [self addSubview:_valueLabel];
    
    _nameLabel.text = @"开盘";
    _valueLabel.text = @"17.30";
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [_nameLabel sizeToFit];
    [_valueLabel sizeToFit];
    
    _nameLabel.frame = (CGRect){0, self.bounds.size.height-_nameLabel.bounds.size.height, _nameLabel.bounds.size.width, _nameLabel.bounds.size.height};
    _valueLabel.frame = (CGRect){self.bounds.size.width-_valueLabel.bounds.size.width, CGRectGetMinY(_nameLabel.frame), _valueLabel.bounds.size.width, _valueLabel.bounds.size.height};
}

@end

#define kBottomBtnH 17
@interface StockTabView()

@property (nonatomic, strong) UIView *cellsView;
@property (nonatomic, strong) NSMutableArray<StockTabDrawerViewCell *> *cells;

@property (nonatomic, strong) UIButton *bottomBtn;

@property (nonatomic, assign) BOOL closed;

@end

@implementation StockTabView

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
    self.closed = YES;
    self.backgroundColor = [UIColor whiteColor];
    self.cellHeight = 21;
    self.clipsToBounds = YES;
    
    self.cellsView = [UIView new];
    [self addSubview:self.cellsView];
    
    self.bottomBtn = [UIButton new];
    [self addSubview:self.bottomBtn];
    [self.bottomBtn setImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    self.bottomBtn.backgroundColor = [YJHelper sharedHelper].color5;
    [self.bottomBtn addTarget:self action:@selector(clickOnBottomBtn:) forControlEvents:UIControlEventTouchUpInside];
}

- (NSMutableArray<StockTabDrawerViewCell *> *)cells
{
    if (!_cells) {
        _cells = @[].mutableCopy;
    }
    return _cells;
}

- (void)reloadWithSetting:(void (^)(NSUInteger, UILabel *, UILabel *, BOOL *))settingHandler
{
    if (!settingHandler) return;
    NSInteger idx = 0;
    BOOL stop = false;
    while (!stop) {
        StockTabDrawerViewCell *cell = [self getCellAtIndex:idx];
        settingHandler(idx, cell.nameLabel, cell.valueLabel, &stop);
        idx ++;
    }
    if (self.cells.count > idx) {
        NSArray *cells = [self.cells subarrayWithRange:(NSRange){idx, self.cells.count-idx+1}];
        [cells makeObjectsPerformSelector:@selector(removeFromSuperview)];
        [self.cells removeObjectsInArray:cells];
    }
    [self excuteHeightChange];
}

- (StockTabDrawerViewCell *)getCellAtIndex:(NSUInteger)idx
{
    if (_cells.count > idx) return self.cells[idx];
    
    StockTabDrawerViewCell *cell = [StockTabDrawerViewCell new];
    [self.cells addObject:cell];
    [self.cellsView addSubview:cell];
    return cell;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat inset = 15, space = 30, h = self.cellHeight, topInset = 0;
    CGFloat w = (CGRectGetWidth(self.bounds) - space * 2 - inset * 2) / 3.;
    
    __block CGFloat closedH = 0;
    [self.cells enumerateObjectsUsingBlock:^(StockTabDrawerViewCell * _Nonnull cell, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat x = idx % 3 == 0 ? inset : ((w + space) * (idx % 3) + inset);
        CGFloat y = idx / 3 * h + topInset;
        cell.frame = (CGRect){x, y, w, h};
        if (idx < 4 && idx % 3 == 0) {
            closedH += h;
        }
    }];
    self.cellsView.frame = CGRectMake(0, 0, CGRectGetWidth(self.bounds), (self.closed && self.cells.count > 0) ? closedH : CGRectGetMaxY(self.cells.lastObject.frame));
    if (self.cells.count == 0) {
        self.bottomBtn.hidden = YES;
    } else {
        self.bottomBtn.hidden = NO;
        self.bottomBtn.frame = CGRectMake(0, CGRectGetMaxY(self.cellsView.frame), CGRectGetWidth(self.bounds), kBottomBtnH);
    }
}

- (void)clickOnBottomBtn:(UIButton *)sender
{
    self.closed = !self.closed;
    
    if (self.closed) {
        self.bottomBtn.imageView.transform = CGAffineTransformIdentity;
    } else {
        self.bottomBtn.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    }
    
    [self excuteHeightChange];
}

- (void)excuteHeightChange
{
    if (self.heightChange) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsLayout];
            [self layoutIfNeeded];
            
            CGFloat height = CGRectGetMaxY(self.bottomBtn.frame);
            CGRect bounds = self.bounds;
            bounds.size.height = height;
            self.bounds = bounds;
            self.heightChange(height);
        });
    }
}

@end















