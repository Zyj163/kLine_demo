//
//  ViewModelConnector.m
//  myJsApp
//
//  Created by 张永俊 on 2017/11/15.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "ViewModelConnector.h"
#import "YJHelper.h"

@implementation ViewModelConnector

+ (void)connectorPortraitStockTitleView:(PortraitStockTitleView *)portraitTitleView withStock:(YJStockModel *)stock
{
    [portraitTitleView resetFlags];
    [portraitTitleView addFlag:[UIImage imageNamed:@"CN"]];
    [portraitTitleView addFlag:[UIImage imageNamed:@"l2"]];
    [portraitTitleView addFlag:[UIImage imageNamed:@"rong"]];
    [portraitTitleView addFlag:[UIImage imageNamed:@"HK"]];
    
    YJHelper *helper = [YJHelper sharedHelper];
    NSString *nClose = [NSString stringWithFormat:@"%.2f", stock.nClose.doubleValue];
    NSString *preClose = [NSString stringWithFormat:@"%.2f", stock.preClosePrice.doubleValue];
    
    NSUInteger diffLocation = [YJHelper firstDiffCharLocationBetween:nClose and:preClose];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:nClose];
    
    [attrStr addAttribute:NSForegroundColorAttributeName value:helper.color1 range:(NSRange){0, diffLocation}];
    UIColor *color = helper.color2;
    if (stock.yield.doubleValue > 0) {
        color = helper.color6;
    } else if (stock.yield.doubleValue < 0) {
        color = helper.color7;
    }
    [attrStr addAttribute:NSForegroundColorAttributeName value:color range:(NSRange){diffLocation, nClose.length-diffLocation}];
    
    portraitTitleView.mainTitleLabel.attributedText = attrStr;
    
    CGFloat yield = stock.yield.doubleValue;
    portraitTitleView.sectionTitleLabel.text = [NSString stringWithFormat:@"%@%.2f", yield > 0 ? @"+" : @"", yield];
    portraitTitleView.sectionTitleLabel.textColor = color;
    portraitTitleView.thirdTitleLabel.text = [NSString stringWithFormat:@"%@%.2f%%", yield > 0 ? @"+" : @"", stock.changePercent.doubleValue];
    portraitTitleView.thirdTitleLabel.textColor = color;
    portraitTitleView.subTitleLabel.text = [NSString stringWithFormat:@"%@,%@ 北京时间", stock.chStatusName, [YJHelper formatTimeFrom:stock withType:YJStockTypeNone]];
}

+ (void)connectorStockTabView:(StockTabView *)tabView withStock:(YJStockModel *)stock
{
    NSArray *keyValues = stock.yj_keyValues;
    [tabView reloadWithSetting:^(NSUInteger idx, UILabel *nameLabel, UILabel *valueLabel, BOOL *stop) {
        NSDictionary *dic = keyValues[idx];
        
        NSString *name = dic.allKeys.firstObject;
        id value = dic.allValues.firstObject;
        if ([value isKindOfClass:[NSNumber class]]) {
            CGFloat num = [(NSNumber *)value doubleValue];
            if (num > 0) {
                valueLabel.textColor = [YJHelper sharedHelper].color6;
            } else if (num < 0) {
                valueLabel.textColor = [YJHelper sharedHelper].color7;
            } else {
                valueLabel.textColor = [YJHelper sharedHelper].color1;
            }
            value = [(NSNumber *)value stringValue];
        }
        
        nameLabel.text = name;
        valueLabel.text = value;
        
        *stop = idx == keyValues.count - 1;
    }];
}

+ (void)connectorLevelInfo:(WuDangInfoView *)wudangView withLevels:(NSArray<YJLevelInfoModel *> *)levels curP:(CGFloat)curP
{
    if (!levels || levels.count != 10) return;
    CGFloat maxSellCount = [[[levels subarrayWithRange:(NSRange){0, 5}] valueForKeyPath:@"@max.iVolume"] doubleValue];
    CGFloat maxBuyCount = [[[levels subarrayWithRange:(NSRange){5, 5}] valueForKeyPath:@"@max.iVolume"] doubleValue];
    if (isnan(curP)) {
        curP = 0;
    }
    [wudangView reload:^(NSUInteger i, UILabel *leftLabel, UILabel *centerLabel, UILabel *rightLabel, CALayer *rightLayer) {
        CGFloat totalW = rightLabel.bounds.size.width;
        if (i < 5) {
            leftLabel.text = [NSString stringWithFormat:@"卖%zd", 5-i];
            if (maxSellCount > 0) {
                rightLayer.backgroundColor = [YJHelper sharedHelper].levelDeclineBGColor.CGColor;
                CGRect bounds = rightLayer.bounds;
                bounds.size.width = totalW * levels[i].iVolume.doubleValue / maxSellCount;
                rightLayer.bounds = bounds;
            }
        } else {
            rightLayer.backgroundColor = [YJHelper sharedHelper].levelGrowBGColor.CGColor;
            leftLabel.text = [NSString stringWithFormat:@"买%zd", i - 4];
            if (maxBuyCount > 0) {
                CGRect bounds = rightLayer.bounds;
                bounds.size.width = totalW * levels[i].iVolume.doubleValue / maxBuyCount;
                rightLayer.bounds = bounds;
            }
        }
        UIColor *color;
        if (levels[i].iTurover.doubleValue >= curP) {
            color = [YJHelper sharedHelper].color6;
        } else {
            color = [YJHelper sharedHelper].color7;
        }
        centerLabel.textColor = color;
        centerLabel.text = [NSString stringWithFormat:@"%.2f", levels[i].iTurover.doubleValue];
        
        rightLabel.text = levels[i].iVolume.stringValue;
        
    }];
}

@end
