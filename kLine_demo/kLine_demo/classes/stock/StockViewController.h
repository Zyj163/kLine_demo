//
//  StockViewController.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/16.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIWindow+YJExtension.h"
#import "YJTransition.h"
#import "YJStockViewable.h"

@interface StockViewController : UIViewController

@property (nonatomic, strong) UIView<YJStockViewable> *mainView;

@end
