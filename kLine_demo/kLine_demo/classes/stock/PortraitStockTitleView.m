//
//  PortraitStockTitleView.m
//  myJsApp
//
//  Created by 张永俊 on 2017/10/11.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "PortraitStockTitleView.h"
#import "YJHelper.h"

@interface PortraitStockTitleView()

@property (weak, nonatomic) IBOutlet UIView *topContainerView;
@property (weak, nonatomic) IBOutlet UIView *bottomContainerView;
@property (weak, nonatomic) IBOutlet UIView *seperateLine;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topContainerBottomConstraint;

@property (nonatomic, strong) NSMutableArray<UIImageView *> *flags;

@end

@implementation PortraitStockTitleView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    YJHelper *helper = [YJHelper sharedHelper];
    
    self.mainTitleLabel.font = helper.fontH;
    self.mainTitleLabel.textColor = helper.color1;
    
    self.sectionTitleLabel.font = helper.fontB;
    self.sectionTitleLabel.textColor = helper.color2;
    
    self.thirdTitleLabel.font = helper.fontB;
    self.thirdTitleLabel.textColor = helper.color2;
    
    self.subTitleLabel.font = helper.fontF;
    self.subTitleLabel.textColor = helper.color3;
    
    UIFont *f = [YJHelper scaleHFont:helper.fontF];
    self.bottomFirstTitleNameLabel.font = f;
    self.bottomFirstTitleNameLabel.textColor = helper.color3;
    self.bottomFirstTitleFirstValueLabel.textColor = helper.color2;
    self.bottomFirstTitleSecondValueLabel.textColor = helper.color2;
    
    self.bottomFirstTitleFirstValueLabel.font = f;
    self.bottomFirstTitleSecondValueLabel.font = f;
    
    self.bottomSecondTitleNameLabel.font = f;
    self.bottomSecondTitleNameLabel.textColor = helper.color3;
    
    self.bottomSecondTitleValueLabel.font = f;
    self.bottomSecondTitleValueLabel.textColor = helper.color6;
    self.bottomSecondTitleValueLabel.textColor = helper.color2;
    
    self.bottomThirdLabel.font = f;
    self.bottomThirdLabel.textColor = helper.color3;
}

- (NSMutableArray *)flags
{
    if (!_flags) {
        _flags = [NSMutableArray array];
    }
    return _flags;
}

- (void)resetFlags
{
    [self.flags makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.flags removeAllObjects];
}

- (void)addFlag:(UIImage *)image
{
    if (!image) return;
    
    UIImageView *flag = [[UIImageView alloc] initWithImage:image];
    [self.flags addObject:flag];
    [self.topContainerView addSubview:flag];
    
    [self layoutFlagWhenAddAtIndex:self.flags.count - 1];
}

- (void)addFlagFromNet:(void (^)(UIImageView *))loadBlock
{
    if (!loadBlock) return;
    UIImageView *flag = [UIImageView new];
    flag.backgroundColor = [UIColor redColor];
    [self.flags addObject:flag];
    [self.topContainerView addSubview:flag];
    loadBlock(flag);
    
    [self layoutFlagWhenAddAtIndex:self.flags.count - 1];
}

- (void)layoutFlagWhenAddAtIndex:(NSInteger)index
{
    CGFloat w = 16;
    CGFloat h = 16;
    CGFloat y = 10;
    CGFloat rightInset = 15;
    CGFloat space = 5;
    
    UIImageView *flag = self.flags[index];
    CGFloat x = CGRectGetWidth(self.bounds) - rightInset - w * (index + 1) - space * index;
    flag.frame = (CGRect){x, y, w, h};
}

+ (instancetype)portraitView
{
    return [[NSBundle mainBundle] loadNibNamed:@"PortraitStockTitleView" owner:nil options:nil][0];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    __weak typeof(self) ws = self;
    [_flags enumerateObjectsUsingBlock:^(UIImageView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [ws layoutFlagWhenAddAtIndex:idx];
    }];
}

- (void)removeBottomView
{
    [self.bottomContainerView removeFromSuperview];
    [self.seperateLine removeFromSuperview];
    self.topContainerBottomConstraint.constant = 0;
}

@end
