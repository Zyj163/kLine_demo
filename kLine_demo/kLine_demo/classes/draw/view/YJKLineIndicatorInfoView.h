//
//  YJKLineIndicatorInfoView.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/25.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJKLineIndicatorInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *topFirstLabel;
@property (weak, nonatomic) IBOutlet UILabel *topSecondNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topSecondValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *topThirdNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topThirdValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *topForthNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *topForthValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomFirstLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomSecondNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomSecondValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomThirdNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomThirdValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomForthNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomForthValueLabel;


+ (instancetype)klineIndicatorInfoView;
@end
