//
//  YJStockModel.m
//  myJsApp
//
//  Created by 张永俊 on 2017/10/12.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "YJStockModel.h"
#import "YJHelper.h"

@interface YJStockModel()

@property (nonatomic, strong) NSMutableDictionary *avgs;

@end

@implementation YJStockModel

+ (NSArray<NSString *> *)modelPropertyBlacklist
{
    return @[@"date"];
}

- (NSMutableDictionary<NSNumber *, NSString *> *)formatTimes
{
    if (!_formatTimes) {
        _formatTimes = [NSMutableDictionary dictionary];
    }
    return _formatTimes;
}
    
- (NSMutableDictionary *)avgs
{
    if (!_avgs) {
        _avgs = [NSMutableDictionary dictionary];
    }
    return _avgs;
}
    
- (NSMutableDictionary<NSNumber *,NSNumber *> *)lines
{
    if (!_lines) {
        _lines = [NSMutableDictionary dictionary];
    }
    return _lines;
}

- (CGFloat)avgForMA:(NSUInteger)count
{
    NSNumber *avg = self.avgs[@(count)];
    if (avg) {
        return avg.doubleValue;
    }
    return 0;
}

- (void)setAvg:(CGFloat)avg forMA:(NSUInteger)count
{
    self.avgs[@(count)] = @(avg);
}

- (void)setTime:(NSString *)time
{
    _time = [time copy];
    self.date = [YJHelper parseDateFromString:time];
}

- (void)setDate:(NSDate *)date
{
    _date = date;
    {
        NSCalendar *canlendar = [NSCalendar currentCalendar];
        NSDateComponents *components = [canlendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:date];
        _year = components.year;
        _month = components.month;
        _day = components.day;
        _week = components.weekday;
        _hour = components.hour;
        _minute = components.minute;
        _second = components.second;
    }
}

- (UIColor *)color
{
    if (self.nOpen > self.nClose) return [UIColor greenColor];
    return [UIColor redColor];
}

- (NSArray<NSDictionary *> *)yj_keyValues
{
    return @[
             @{@"开盘": self.nOpen ?: @"--"},
             @{@"最高": self.nHigh ?: @"--"},
             @{@"成交量": self.nMatchItems ?: @"--"},
             @{@"昨收": self.preClosePrice ?: @"--"},
             @{@"最低": self.nLow ?: @"--"},
             @{@"换手率": @"--"},
             @{@"涨停": @"--"},
             @{@"总市值": @"--"},
             @{@"振幅": @"--"},
             @{@"量比": @"--"},
             @{@"市盈率(动)": @"--"},
             @{@"股息": @"--"},
             @{@"委比": @"--"},
             @{@"每股收益": @"--"},
             @{@"股息率": @"--"}
             ];
}

- (NSNumber *)absYield
{
    return @(ABS(self.nClose.doubleValue - self.preClosePrice.doubleValue));
}

- (NSString *)chStatusName
{
    return @"交易中";
}

@end
