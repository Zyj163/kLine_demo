//
//  StockViewController.m
//  myJsApp
//
//  Created by 张永俊 on 2017/10/16.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "StockViewController.h"

@interface StockViewController ()


@end

@implementation StockViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)setMainView:(UIView<YJStockViewable> *)mainView
{
    [_mainView removeFromSuperview];
    _mainView = mainView;
    [self.view addSubview:mainView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _mainView.frame = self.view.bounds;
    [_mainView draw];
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationLandscapeRight;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskLandscapeRight | UIInterfaceOrientationMaskLandscapeLeft;
}

@end
