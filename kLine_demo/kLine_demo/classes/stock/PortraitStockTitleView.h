//
//  PortraitStockTitleView.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/11.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortraitStockTitleView : UIView

@property (nonatomic, weak) IBOutlet UILabel *mainTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *sectionTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *thirdTitleLabel;

@property (nonatomic, weak) IBOutlet UILabel *subTitleLabel;

@property (weak, nonatomic) IBOutlet UILabel *bottomFirstTitleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomFirstTitleFirstValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomFirstTitleSecondValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomSecondTitleNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomSecondTitleValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomThirdLabel;


+ (instancetype)portraitView;

- (void)addFlag:(UIImage *)image;

- (void)addFlagFromNet:(void(^)(UIImageView *))loadBlock;

- (void)resetFlags;

- (void)removeBottomView;

@end
