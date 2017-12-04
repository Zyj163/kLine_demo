//
//  WuDangInfoView.h
//  myJsApp
//
//  Created by 张永俊 on 2017/11/17.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WuDangInfoView : UIView

- (void)reload:(void(^)(NSUInteger, UILabel *, UILabel *, UILabel *, CALayer *))setting;

@end
