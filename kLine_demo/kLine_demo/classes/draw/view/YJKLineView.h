//
//  YJKLineView.h
//  KLine
//
//  Created by 张永俊 on 2017/10/10.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJKLineDrawerConnector.h"
#import "YJStockViewable.h"

@interface YJKLineView : UIView <YJStockViewable>

@property (nonatomic, strong) YJKLineDrawerConnector *connector;

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
