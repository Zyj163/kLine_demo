//
//  YJLevelInfoModel.h
//  myJsApp
//
//  Created by 张永俊 on 2017/11/27.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YJLevelInfoModel : NSObject

@property (nonatomic, copy) NSString *levelIndex;//档位等级
@property (nonatomic, assign) int leveltype;
@property (nonatomic, strong) NSNumber *iVolume;
@property (nonatomic, strong) NSNumber *iTurover;
@property (nonatomic, copy) NSString *time;

@end
