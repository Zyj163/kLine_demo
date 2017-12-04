//
//  StockView.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/11.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJHelper.h"

typedef void(^EventBlock)(NSDictionary *);

@interface StockView : UIView

@property (nonatomic, copy) EventBlock onLeftRefresh;
@property (nonatomic, copy) EventBlock onRightRefresh;
@property (nonatomic, copy) EventBlock onHeightChange;

@property (nonatomic, copy) EventBlock onStockTypeChange;

@property (nonatomic, copy) EventBlock onOriginChange;

@property (nonatomic, assign) CGFloat originChangeValue;
@property (nonatomic, copy) NSString *chJsCode;

- (void)refresh:(id)json type:(YJStockType)type;
- (void)append:(id)json type:(YJStockType)type;
- (void)insert:(id)json type:(YJStockType)type;
- (void)fluc:(id)json;
- (void)level:(id)json;

- (void)selectType:(YJStockType)type;

@end
