//
//  YJTrendIndicatorInfoView.m
//  myJsApp
//
//  Created by 张永俊 on 2017/10/19.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "YJTrendIndicatorInfoView.h"
#import "YJHelper.h"

@implementation YJTrendIndicatorInfoView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.leftLabel.font = self.centerLabel.font = self.rightLabel.font = [YJHelper scaleHFont:[YJHelper sharedHelper].fontF];
    self.leftLabel.textColor = self.centerLabel.textColor = self.rightLabel.textColor = [YJHelper sharedHelper].color3;
    self.backgroundColor = [UIColor clearColor];
}

+ (instancetype)trendIndicatorInfoView
{
    return [[NSBundle mainBundle] loadNibNamed:@"YJTrendIndicatorInfoView" owner:nil options:nil][0];
}

@end
