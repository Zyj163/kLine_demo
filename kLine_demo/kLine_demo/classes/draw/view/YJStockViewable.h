//
//  YJStockViewable.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/16.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJDrawerConnector.h"
@protocol YJStockViewable;

@protocol YJStockViewableDelegate <NSObject>

@optional
- (void)stockViewBeginRightRefresh:(UIView<YJStockViewable> *)stockView;
@optional
- (void)stockViewBeginLeftRefresh:(UIView<YJStockViewable> *)stockView;
@optional
- (void)stockView:(UIView<YJStockViewable> *)stockView beTapedOn:(CGPoint)location;

@end

@protocol YJStockViewable <NSObject>

@property (nonatomic, strong) YJDrawerConnector *connector;

@property (nonatomic, strong) NSMutableArray<YJStockModel *> *datas;

@property (nonatomic, strong) dispatch_queue_t prepareQueue;

@property (nonatomic, weak) id<YJStockViewableDelegate> delegate;

- (void)draw;
- (void)drawWithCompletionHandler:(void(^)())handler;

- (void)showHUD;
- (void)hideHUD;

@property (nonatomic, assign) BOOL leftRefreshing;
@property (nonatomic, assign) BOOL rightRefreshing;

@end
