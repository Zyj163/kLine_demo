//
//  YJCandleDrawer.m
//  KLine
//
//  Created by 张永俊 on 2017/9/28.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJCandleDrawer.h"

@implementation YJCandleDrawer

- (void)resetLayers
{
    NSMutableArray *layers = [NSMutableArray array];
    
    self.lineDrawer.color = self.color;
    self.shapeDrawer.color = self.color;
    self.shapeDrawer.fillColor = self.color;
    [self.lineDrawer resetLayers];
    [layers addObjectsFromArray:self.lineDrawer.layers];
    [self.shapeDrawer resetLayers];
    [layers addObjectsFromArray:self.shapeDrawer.layers];
    
    _layers = [layers copy];
}

- (void)drawInContext:(CGContextRef)ctx
{
    if (self.lineDrawer) {
        
        self.lineDrawer.color = self.color;
        
        [self.lineDrawer drawInContext:ctx];
    }
    if (self.shapeDrawer) {
        
        self.shapeDrawer.color = self.color;
        self.shapeDrawer.fillColor = self.color;
        
        [self.shapeDrawer drawInContext:ctx];
    }
}

@end
