//
//  CALayer+YJExtension.m
//  myJsApp
//
//  Created by 张永俊 on 2017/11/20.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "CALayer+YJExtension.h"
#import <objc/runtime.h>

@implementation CALayer (YJExtension)

- (void)setWeakObj:(id)weakObj
{
    objc_setAssociatedObject(self, _cmd, weakObj, OBJC_ASSOCIATION_ASSIGN);
}

- (id)weakObj
{
    return objc_getAssociatedObject(self, @selector(setWeakObj:));
}

@end
