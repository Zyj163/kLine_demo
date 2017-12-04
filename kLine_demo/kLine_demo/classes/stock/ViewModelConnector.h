//
//  ViewModelConnector.h
//  myJsApp
//
//  Created by 张永俊 on 2017/11/15.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StockView.h"
#import "PortraitStockTitleView.h"
#import "StockTabView.h"
#import "YJStockModel.h"
#import "YJLevelInfoModel.h"
#import "WuDangInfoView.h"

@interface ViewModelConnector : NSObject

+ (void)connectorPortraitStockTitleView:(PortraitStockTitleView *)portraitTitleView withStock:(YJStockModel *)stock;

+ (void)connectorStockTabView:(StockTabView *)tabView withStock:(YJStockModel *)stock;

+ (void)connectorLevelInfo:(WuDangInfoView *)wudangView withLevels:(NSArray<YJLevelInfoModel *> *)levels curP:(CGFloat)curP;

@end
