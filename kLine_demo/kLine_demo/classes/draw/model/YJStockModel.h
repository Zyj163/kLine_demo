//
//  YJStockModel.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/12.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYModel/YYModel.h>

@interface YJStockModel : NSObject <YYModel>

@property (nonatomic, copy) NSString *chCode;//股票代码
@property (nonatomic, copy) NSString *chJsCode;//嘉实代码
@property (nonatomic, copy) NSString *chCNName;//中文名
@property (nonatomic, strong) NSNumber *nOpen;//开盘
@property (nonatomic, strong) NSNumber *nHigh;//最高
@property (nonatomic, strong) NSNumber *nLow;//最低
@property (nonatomic, strong) NSNumber *nClose;//收盘/当前
@property (nonatomic, strong) NSNumber *iVolume;//成交量
@property (nonatomic, strong) NSNumber *iTurover;//成交额
@property (nonatomic, strong) NSNumber *nMatchItems;//成交笔数
@property (nonatomic, strong) NSNumber *chStatus;//状态
@property (nonatomic, strong) NSNumber *preClosePrice;//昨日收盘价
@property (nonatomic, copy) NSString *chStatusName;

@property (nonatomic, strong) NSNumber *yield;//涨跌额
@property (nonatomic, strong) NSNumber *changePercent;//涨跌幅
@property (nonatomic, strong, readonly) NSNumber *absYield;

@property (nonatomic, copy) NSString *time;
@property (nonatomic, strong) NSDate *date;//时间

@property (nonatomic, assign, readonly) NSInteger month;
@property (nonatomic, assign, readonly) NSInteger year;
@property (nonatomic, assign, readonly) NSInteger day;
@property (nonatomic, assign, readonly) NSInteger week;
@property (nonatomic, assign, readonly) NSInteger hour;
@property (nonatomic, assign, readonly) NSInteger minute;
@property (nonatomic, assign, readonly) NSInteger second;
  
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSString *> *formatTimes;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *lines;

- (void)setAvg:(CGFloat)avg forMA:(NSUInteger)count;
- (CGFloat)avgForMA:(NSUInteger)count;

- (NSArray<NSDictionary *> *)yj_keyValues;

@end
