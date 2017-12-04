//
//  YJHelper.m
//  myJsApp
//
//  Created by 张永俊 on 2017/10/13.
//  Copyright © 2017年 Facebook. All rights reserved.
//
#import "YJHelper.h"

static inline NSDate *YJDateFromString(__unsafe_unretained NSString *string) {
    typedef NSDate* (^DateParseBlock)(NSString *string);
#define kParserLength 17
    static DateParseBlock blocks[kParserLength + 1] = {0};
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter.dateFormat = @"yyyyMMdd";
            blocks[8] = ^(NSString *string) { return [formatter dateFromString:string]; };
        }
        
        {
            
            NSDateFormatter *formatter2 = [[NSDateFormatter alloc] init];
            formatter2.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter2.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter2.dateFormat = @"yyyyMMddHHmmss";
            
            NSDateFormatter *formatter4 = [[NSDateFormatter alloc] init];
            formatter4.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
            formatter4.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
            formatter4.dateFormat = @"yyyyMMddHHmmssSSS";
            
            blocks[14] = ^(NSString *string) {
                return [formatter2 dateFromString:string];
            };
            
            blocks[17] = ^(NSString *string) {
                return [formatter4 dateFromString:string];
            };
        }
    });
    if (!string) return nil;
    if (string.length > kParserLength) return nil;
    DateParseBlock parser = blocks[string.length];
    if (!parser) return nil;
    return parser(string);
#undef kParserLength
}

NSString *const YJStockViewTypeKey = @"stockTypeKey";

@implementation YJHelper

YJSingleton_m(Helper)

- (instancetype)init
{
    if (self = [super init]) {
        self.fontA = [UIFont systemFontOfSize:18];
        self.fontB = [UIFont systemFontOfSize:16];
        self.fontC = [UIFont systemFontOfSize:15];
        self.fontD = [UIFont systemFontOfSize:14];
        self.fontE = [UIFont systemFontOfSize:13];
        self.fontF = [UIFont systemFontOfSize:12];
        self.fontG = [UIFont systemFontOfSize:24];
        self.fontH = [UIFont systemFontOfSize:34];
        self.fontK = [UIFont systemFontOfSize:11];
        
        self.color1 = [YJHelper colorFromString:@"#404040"];
        self.color2 = [YJHelper colorFromString:@"#808080"];
        self.color3 = [YJHelper colorFromString:@"#999999"];
        self.color4 = [YJHelper colorFromString:@"#cccccc"];
        self.color5 = [YJHelper colorFromString:@"#ffffff"];
        self.color6 = [YJHelper colorFromString:@"#ff214c"];
        self.color7 = [YJHelper colorFromString:@"#39b948"];
        self.color8 = [YJHelper colorFromString:@"#508cee"];
        self.color9 = [YJHelper colorFromString:@"#ff9011"];
        self.color10 = [YJHelper colorFromString:@"#d1b684"];
        
        self.growColor = [YJHelper colorFromString:@"#FA5456"];
        self.declineColor = [YJHelper colorFromString:@"#00D391"];
        self.holdColor = [YJHelper colorFromString:@"#cdcdcd"];
        self.backgroundColor = [YJHelper colorFromString:@"#f9f9f9"];
        self.backgroundGrowColor = [[YJHelper colorFromString:@"#fc7786"] colorWithAlphaComponent:0.3];
        self.backgroundDeclineColor = [[YJHelper colorFromString:@"#5fd46b"] colorWithAlphaComponent:0.3];
        self.minuteLineColor = [YJHelper colorFromString:@"#509eff"];
        
        self.MAColor = [YJHelper colorFromString:@"#509eff"];
        self.MA5Color = [YJHelper colorFromString:@"#efb83d"];
        self.MA10Color = [YJHelper colorFromString:@"#ff3248"];
        self.MA20Color = [YJHelper colorFromString:@"#d548f5"];
        self.MA30Color = [YJHelper colorFromString:@"#2446a9"];
        
        self.indicatorLineColor = self.indicatorTextColor = [YJHelper colorFromString:@"#404040"];
        self.indicatorLabelColor = [YJHelper colorFromString:@"#f0f0f0"];
        
        self.levelGrowBGColor = [[YJHelper colorFromString:@"#fc7786"] colorWithAlphaComponent:0.3];
        self.levelDeclineBGColor = [[YJHelper colorFromString:@"#5fd46b"] colorWithAlphaComponent:0.3];
    }
    return self;
}
    
+ (BOOL)stock:(YJStockModel *)stock hasLineForType:(YJStockType)type preStock:(YJStockModel *)preStock
{
    if (!preStock) return YES;
    NSNumber *has = stock.lines[@(type)];
    if (has) return has.boolValue;
    
//    switch (type) {
//        case YJStockTypeMonth: //一月一线
//        {
            if (preStock.month == stock.month) {
                has = @NO;
            }
            has = @YES;
//            break;
//        }
//
//        default:
//            break;
//    }
    stock.lines[@(type)] = has;
    return has.boolValue;
}
    
+ (NSString *)formatTimeFrom:(YJStockModel *)stock withType:(YJStockType)type
{
    NSString *time = stock.formatTimes[@(type)];
    if (time) return time;
    
    switch (type) {
        case YJStockTypeEachMinute:
        time = [NSString stringWithFormat:@"%02zd:%02zd", stock.hour, stock.minute];
        break;
        case YJStockTypeFiveDay:
        time = [NSString stringWithFormat:@"%02zd-%02zd %02zd:%02zd", stock.month, stock.day, stock.hour, stock.minute];
        break;
        case YJStockTypeMonth:
        time = [NSString stringWithFormat:@"%zd-%02zd", stock.year, stock.month];
        break;
        case YJStockTypeDay:
        time = [NSString stringWithFormat:@"%zd-%02zd-%02zd", stock.year, stock.month, stock.day];
        break;
        default:
        time = [NSString stringWithFormat:@"%zd-%02zd-%02zd %02zd:%02zd", stock.year, stock.month, stock.day, stock.hour, stock.minute];
        break;
    }
    stock.formatTimes[@(type)] = time;
    return time;
}

+ (NSString *)weekDay:(NSInteger)week
{
    switch (week) {
        case 1:
            return @"日";
        case 2:
            return @"一";
        case 3:
            return @"二";
        case 4:
            return @"三";
        case 5:
            return @"四";
        case 6:
            return @"五";
        case 7:
            return @"六";
            
        default:
            return nil;
    }
}

+ (UIColor *)klineColor:(YJStockModel *)stock
{
    YJHelper *helper = [self sharedHelper];
    if (stock.nOpen > stock.nClose) return helper.declineColor;
    return helper.growColor;
}

+ (CGFloat)highest:(NSArray<YJStockModel *> *)stocks
{
    return [[stocks valueForKeyPath:@"@max.nHigh"] doubleValue];
}

+ (CGFloat)lowest:(NSArray<YJStockModel *> *)stocks
{
    return [[stocks valueForKeyPath:@"@min.nLow"] doubleValue];
}

+ (CGFloat)volumest:(NSArray<YJStockModel *> *)stocks
{
    return [[stocks valueForKeyPath:@"@max.iVolume"] doubleValue];
}

+ (void)prePrepareAVGs:(NSArray<YJStockModel *> *)stocks counts:(NSArray<NSNumber *> *)counts
{
    [stocks enumerateObjectsUsingBlock:^(YJStockModel * _Nonnull stock, NSUInteger idx, BOOL * _Nonnull stop) {
        [counts enumerateObjectsUsingBlock:^(NSNumber * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self avg:stocks currentStock:stock count:obj.unsignedIntegerValue];
        }];
    }];
}

+ (CGFloat)avg:(NSArray<YJStockModel *> *)stocks currentStock:(YJStockModel *)stock count:(NSUInteger)count
{
    CGFloat avg = [stock avgForMA:count];
    if (avg) return avg;
    NSUInteger index = [stocks indexOfObject:stock];
    if (index > stocks.count - 1) return stock.nClose.doubleValue;
    
    NSRange range;
    if (index >= count - 1) {
        range = NSMakeRange(index - count + 1, count);
        avg = [[[stocks subarrayWithRange:range] valueForKeyPath:@"@avg.nClose"] doubleValue];
        [stock setAvg:avg forMA:count];
    } else {
        range = NSMakeRange(0, index+1);
        avg = [[[stocks subarrayWithRange:range] valueForKeyPath:@"@avg.nClose"] doubleValue];
    }
    return avg;
}

+ (UIColor *)MAColor:(NSUInteger)count
{
    YJHelper *helper = [YJHelper sharedHelper];
    if (count == 5) {
        return helper.MA5Color;
    } else if (count == 10) {
        return helper.MA10Color;
    } else if (count == 20) {
        return helper.MA20Color;
    } else if (count == 30) {
        return helper.MA30Color;
    }
    return helper.MAColor;
}

+ (UIColor *)colorFromString:(NSString *)colorStr
{
    NSString *cString = [[colorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString hasPrefix:@"#"]) cString = [cString substringFromIndex:1];
    if ([cString length] != 6) return nil;
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+ (NSDictionary *)bridgeStockType
{
    return @{
             @"eachMinute": @(YJStockTypeEachMinute),
             @"fiveDay": @(YJStockTypeFiveDay),
             @"day": @(YJStockTypeDay),
             @"week": @(YJStockTypeWeek),
             @"month": @(YJStockTypeMonth),
             @"minute": @(YJStockTypeMinute)
             };
}

+ (YJStockType)stockTypeFromBridge:(NSString *)bridgeType
{
    return [[self bridgeStockType][bridgeType] integerValue];
}

+ (NSString *)bridgeStockForType:(YJStockType)type
{
    NSDictionary *b = [self bridgeStockType];
    return [b allKeysForObject:@(type)].firstObject;
}

+ (UIFont *)scaleHFont:(UIFont *)font
{
    return [UIFont systemFontOfSize:font.pointSize/375.*[UIScreen mainScreen].bounds.size.width];
}

+ (NSUInteger)firstDiffCharLocationBetween:(NSString *)str and:(NSString *)str2
{
    if (!str || !str2) return 0;
    
    NSUInteger location = [str rangeOfString:@"."].location;
    NSUInteger location2 = [str2 rangeOfString:@"."].location;
    
    if (location != location2) return 0;
    
    for (NSInteger i=0; i<MIN(str.length, str2.length); i++) {
        unichar c = [str characterAtIndex:i];
        unichar c2 = [str2 characterAtIndex:i];
        if (c != c2) {
            return i;
        }
    }
    return MIN(str.length, str2.length);
}

+ (void)compareMinute:(YJStockModel *)stock and:(YJStockModel *)newStock cirticalValue:(NSInteger)hour minute:(NSInteger)minute newHour:(NSInteger)newHour newMinute:(NSInteger)newMinute ifUpdate:(void (^)())update ifAppend:(void (^)())append ifReset:(void(^)())reset
{
    if ([newStock.date timeIntervalSinceDate:stock.date] <= 0) return;
    update = update ?: ^{};
    append = append ?: ^{};
    reset = reset ?: ^{};
    
    if ([self sameMinute:stock newStock:newStock]) {
        update();
    } else if ([self nextMinute:stock newStock:newStock]) {
        append();
    } else if (stock.hour == hour && stock.minute == minute && newStock.hour == newHour && newStock.minute == newMinute && [self sameDay:stock newStock:newStock]) {
        append();
    } else {
        reset();
    }
}

+ (void)compareFiveDayMinute:(YJStockModel *)stock and:(YJStockModel *)newStock cirticalValueInSameDay:(NSInteger)hour minute:(NSInteger)minute newHour:(NSInteger)newHour newMinute:(NSInteger)newMinute nextDayTodayHour:(NSInteger)todayHour todayMinute:(NSInteger)todayMinute nextDayHour:(NSInteger)nextDayHour nextDayMinute:(NSInteger)nextDayMinute ifUpdate:(void (^)())update ifAppend:(void (^)())append ifReset:(void(^)())reset
{
    if ([newStock.date timeIntervalSinceDate:stock.date] <= 0) return;
    update = update ?: ^{};
    append = append ?: ^{};
    reset = reset ?: ^{};
    if ([self sameDay:stock newStock:newStock]) {
        [self compareMinute:stock and:newStock cirticalValue:hour minute:minute newHour:newHour newMinute:newMinute ifUpdate:update ifAppend:append ifReset:reset];
    } else if (stock.hour == todayHour && stock.minute == todayMinute && newStock.hour == nextDayHour && newStock.minute == nextDayMinute) {
        append();
    } else {
        reset();
    }
}

+ (void)compareDay:(YJStockModel *)stock and:(YJStockModel *)newStock ifUpdate:(void (^)())update ifAppend:(void (^)())append ifReset:(void(^)())reset
{
    if ([newStock.date timeIntervalSinceDate:stock.date] <= 0) return;
    update = update ?: ^{};
    append = append ?: ^{};
    reset = reset ?: ^{};
    if ([self sameDay:stock newStock:newStock]) {
        update();
    }
    reset();
}

+ (void)compareWeek:(YJStockModel *)stock and:(YJStockModel *)newStock ifUpdate:(void (^)())update ifAppend:(void (^)())append ifReset:(void(^)())reset
{
    if ([newStock.date timeIntervalSinceDate:stock.date] <= 0) return;
    update = update ?: ^{};
    append = append ?: ^{};
    reset = reset ?: ^{};
    if ([self sameWeek:stock newStock:newStock]) {
        update();
    }
    reset();
}

+ (BOOL)sameMinute:(YJStockModel *)stock newStock:(YJStockModel *)newStock
{
    if (stock.minute == newStock.minute && stock.hour == newStock.hour && stock.day == newStock.day && stock.month == newStock.month && stock.year == newStock.year) {
        return YES;
    }
    return NO;
}

+ (BOOL)nextMinute:(YJStockModel *)stock newStock:(YJStockModel *)newStock
{
    if ([newStock.date timeIntervalSinceDate:stock.date] < 120) {
        if (newStock.minute - stock.minute == 1) {
            return YES;
        } else if (newStock.minute == 0 && stock.minute == 59) {
            return YES;
        }
        return NO;
    }
    return NO;
}

+ (BOOL)sameDay:(YJStockModel *)stock newStock:(YJStockModel *)newStock
{
    if (stock.day == newStock.day && stock.month == newStock.month && stock.year == newStock.year) {
        return YES;
    }
    return NO;
}

+ (BOOL)sameWeek:(YJStockModel *)stock newStock:(YJStockModel *)newStock
{
    return stock.week == newStock.week;
}

+ (NSDate *)parseDateFromString:(NSString *)str
{
    return YJDateFromString(str);
}

@end
