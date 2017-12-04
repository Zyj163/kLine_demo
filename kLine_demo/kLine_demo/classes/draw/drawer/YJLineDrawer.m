//
//  YJLineDrawer.m
//  KLine
//
//  Created by 张永俊 on 2017/9/27.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJLineDrawer.h"

@implementation YJLineDrawer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = 1/[UIScreen mainScreen].scale;
    }
    return self;
}

- (NSString *)text
{
    if (!_text) {
        return @"";
    }
    return _text;
}

- (void)resetLayers
{
    NSMutableArray *layers = [NSMutableArray array];
    
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.name = @"line";
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.lineWidth = self.width;
    if (self.dash) {
        layer.lineDashPattern = @[@3, @3];
        layer.lineDashPhase = 1;
    }
    layer.strokeColor = self.color.CGColor;
    if (self.path) {
        layer.path = self.path.CGPath;
    }
    else if (!CGPointEqualToPoint(self.startPoint, self.endPoint)) {
        UIBezierPath *path = [UIBezierPath bezierPath];
        [path moveToPoint:self.startPoint];
        [path addLineToPoint:self.endPoint];
        layer.path = path.CGPath;
    }
    [layers addObject:layer];
    
    _layers = [layers copy];
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
  
    CGContextSetLineWidth(ctx, self.width);
    if (self.dash) {
        CGFloat arr[] = {3, 3};
        CGContextSetLineDash(ctx, 0, arr, 1);
    }
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    
    if (!CGPointEqualToPoint(self.startPoint, self.endPoint)) {
        CGContextMoveToPoint(ctx, self.startPoint.x, self.startPoint.y);
        CGContextAddLineToPoint(ctx, self.endPoint.x, self.endPoint.y);
    }
    
    if (self.path) {
        CGContextAddPath(ctx, self.path.CGPath);
    }
    
    CGContextStrokePath(ctx);
    
    CGContextRestoreGState(ctx);
}

@end
