//
//  StockTabView.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/11.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockTabView : UIView

- (void)reloadWithSetting:(void(^)(NSUInteger idx, UILabel *nameLabel, UILabel *valueLabel, BOOL *stop))settingHandler;

@property (nonatomic, copy) void(^heightChange)(CGFloat height);
@property (nonatomic, assign) CGFloat cellHeight;

@end
