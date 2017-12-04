//
//  YJTab.h
//  myJsApp
//
//  Created by 张永俊 on 2017/11/16.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ClickOnHandler)(NSInteger, NSInteger);

@interface YJTab : UIView

- (void)setupWithTitles:(NSArray<NSString *> *)titles;

- (void)addClickOnHandler:(ClickOnHandler)clickOn;

- (void)setSelected:(NSInteger)idx;

@property (nonatomic, strong) UIColor *normalTitleColor;
@property (nonatomic, strong) UIColor *selectedTitleColor;
@property (nonatomic, strong) UIFont *titleFont;
@property (nonatomic, assign) CGFloat specifyPaddingH;

@end
