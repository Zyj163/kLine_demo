//
//  YJHelper.h
//  myJsApp
//
//  Created by 张永俊 on 2017/10/13.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YJStockModel.h"
#import "YJSingleton.h"

typedef NS_ENUM(NSUInteger, YJStockType) {
  YJStockTypeNone,
  YJStockTypeEachMinute,//分时
  YJStockTypeFiveDay,//5日
  YJStockTypeMinute,//分钟K
  YJStockTypeDay,//日K
  YJStockTypeWeek,//周K
  YJStockTypeMonth//月K
};

UIKIT_EXTERN NSString *const YJStockViewTypeKey;

@interface YJHelper : NSObject

@property (nonatomic, strong) UIFont *fontA;
@property (nonatomic, strong) UIFont *fontB;
@property (nonatomic, strong) UIFont *fontC;
@property (nonatomic, strong) UIFont *fontD;
@property (nonatomic, strong) UIFont *fontE;
@property (nonatomic, strong) UIFont *fontF;
@property (nonatomic, strong) UIFont *fontG;
@property (nonatomic, strong) UIFont *fontH;
@property (nonatomic, strong) UIFont *fontK;

@property (nonatomic, strong) UIColor *color1;
@property (nonatomic, strong) UIColor *color2;
@property (nonatomic, strong) UIColor *color3;
@property (nonatomic, strong) UIColor *color4;
@property (nonatomic, strong) UIColor *color5;
@property (nonatomic, strong) UIColor *color6;
@property (nonatomic, strong) UIColor *color7;
@property (nonatomic, strong) UIColor *color8;
@property (nonatomic, strong) UIColor *color9;
@property (nonatomic, strong) UIColor *color10;

@property (nonatomic, strong) UIColor *growColor;
@property (nonatomic, strong) UIColor *declineColor;
@property (nonatomic, strong) UIColor *holdColor;
@property (nonatomic, strong) UIColor *backgroundColor;
@property (nonatomic, strong) UIColor *backgroundGrowColor;
@property (nonatomic, strong) UIColor *backgroundDeclineColor;
@property (nonatomic, strong) UIColor *minuteLineColor;

@property (nonatomic, strong) UIColor *MAColor;
@property (nonatomic, strong) UIColor *MA5Color;
@property (nonatomic, strong) UIColor *MA10Color;
@property (nonatomic, strong) UIColor *MA20Color;
@property (nonatomic, strong) UIColor *MA30Color;
  
@property (nonatomic, strong) UIColor *indicatorLineColor;
@property (nonatomic, strong) UIColor *indicatorLabelColor;
@property (nonatomic, strong) UIColor *indicatorTextColor;

@property (nonatomic, strong) UIColor *levelGrowBGColor;
@property (nonatomic, strong) UIColor *levelDeclineBGColor;

YJSingleton_h(Helper)

+ (UIColor *)klineColor:(YJStockModel *)stock;
+ (CGFloat)highest:(NSArray<YJStockModel *> *)stocks;
+ (CGFloat)lowest:(NSArray<YJStockModel *> *)stocks;
+ (CGFloat)volumest:(NSArray<YJStockModel *> *)stocks;

+ (CGFloat)avg:(NSArray<YJStockModel *> *)stocks currentStock:(YJStockModel *)stock count:(NSUInteger)count;
+ (void)prePrepareAVGs:(NSArray<YJStockModel *> *)stocks counts:(NSArray<NSNumber *> *)counts;
+ (UIColor *)MAColor:(NSUInteger)count;

+ (NSString *)formatTimeFrom:(YJStockModel *)stock withType:(YJStockType)type;
+ (BOOL)stock:(YJStockModel *)stock hasLineForType:(YJStockType)type preStock:(YJStockModel *)preStock;
+ (NSString *)weekDay:(NSInteger)week;

+ (UIColor *)colorFromString:(NSString *)colorStr;

+ (NSDictionary *)bridgeStockType;
+ (NSString *)bridgeStockForType:(YJStockType)type;
+ (YJStockType)stockTypeFromBridge:(NSString *)bridgeType;

+ (UIFont *)scaleHFont:(UIFont *)font;

+ (NSUInteger)firstDiffCharLocationBetween:(NSString *)str and:(NSString *)str2;


+ (void)compareMinute:(YJStockModel *)stock and:(YJStockModel *)newStock cirticalValue:(NSInteger)hour minute:(NSInteger)minute newHour:(NSInteger)newHour newMinute:(NSInteger)newMinute ifUpdate:(void(^)(void))update ifAppend:(void(^)(void))append ifReset:(void(^)(void))reset;

+ (void)compareFiveDayMinute:(YJStockModel *)stock and:(YJStockModel *)newStock cirticalValueInSameDay:(NSInteger)hour minute:(NSInteger)minute newHour:(NSInteger)newHour newMinute:(NSInteger)newMinute nextDayTodayHour:(NSInteger)todayHour todayMinute:(NSInteger)todayMinute nextDayHour:(NSInteger)nextDayHour nextDayMinute:(NSInteger)nextDayMinute ifUpdate:(void(^)(void))update ifAppend:(void(^)(void))append ifReset:(void(^)(void))reset;

+ (void)compareDay:(YJStockModel *)stock and:(YJStockModel *)newStock ifUpdate:(void(^)(void))update ifAppend:(void(^)(void))append ifReset:(void(^)(void))reset;

+ (void)compareWeek:(YJStockModel *)stock and:(YJStockModel *)newStock ifUpdate:(void(^)(void))update ifAppend:(void(^)(void))append ifReset:(void(^)(void))reset;

+ (NSDate *)parseDateFromString:(NSString *)str;

@end
