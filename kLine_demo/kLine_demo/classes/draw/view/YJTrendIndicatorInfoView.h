//
//  YJTrendIndicatorInfoView.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/19.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YJTrendIndicatorInfoView : UIView

@property (weak, nonatomic) IBOutlet UILabel *leftLabel;
@property (weak, nonatomic) IBOutlet UILabel *centerLabel;
@property (weak, nonatomic) IBOutlet UILabel *rightLabel;

+ (instancetype)trendIndicatorInfoView;

@end
