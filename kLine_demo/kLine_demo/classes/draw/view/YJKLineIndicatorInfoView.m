//
//  YJKLineIndicatorInfoView.m
//  myJsApp
//
//  Created by 张永俊 on 2017/10/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "YJKLineIndicatorInfoView.h"
#import "YJHelper.h"

@implementation YJKLineIndicatorInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    YJHelper *helper = [YJHelper sharedHelper];
    
    [self.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UILabel *nameLabel = (UILabel *)obj.subviews.firstObject;
            nameLabel.font = helper.fontF;
            nameLabel.textColor = helper.color3;
            
            if (obj.subviews.count > 1) {
                UILabel *valueLabel = (UILabel *)obj.subviews.lastObject;
                valueLabel.font = helper.fontF;
                valueLabel.textColor = helper.color1;
            }
        }];
    }];
}

+ (instancetype)klineIndicatorInfoView
{
    return [[NSBundle mainBundle] loadNibNamed:@"YJKLineIndicatorInfoView" owner:nil options:nil][0];
}

@end
