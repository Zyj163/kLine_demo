//
//  YJShapeDrawer.m
//  KLine
//
//  Created by 张永俊 on 2017/9/28.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJShapeDrawer.h"

@implementation YJShapeDrawer

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.closeLineColor = [UIColor clearColor];
        self.fillColor = [UIColor blueColor];
        self.lineWidth = 1/[UIScreen mainScreen].scale;
    }
    return self;
}

- (void)resetLayers
{
    NSMutableArray *layers = [NSMutableArray array];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.name = @"shape";
    shapeLayer.contentsScale = [UIScreen mainScreen].scale;
    UIBezierPath *path;
    if (self.shapePath) {
        path = self.shapePath;
    } else {
        if (!CGRectIsNull(self.frame) && !CGRectIsEmpty(self.frame)) {
            path = [UIBezierPath bezierPathWithRect:CGRectInset(self.frame, self.lineWidth, self.lineWidth)];
        }
    }
    if (path) {
        
        if (!self.needClose) {
            shapeLayer.path = path.CGPath;
            shapeLayer.lineWidth = self.lineWidth;
            switch (self.drawType) {
                case YJShapDrawTypeFill:
                    shapeLayer.fillColor = self.fillColor.CGColor;
                    break;
                case YJShapDrawTypeStroke:
                    shapeLayer.strokeColor = self.color.CGColor;
                    shapeLayer.fillColor = [UIColor clearColor].CGColor;
                    break;
                default:
                    shapeLayer.fillColor = self.fillColor.CGColor;
                    shapeLayer.strokeColor = self.color.CGColor;
                    break;
            }
            [layers addObject:shapeLayer];
        } else {
            
            CAShapeLayer *sl = [CAShapeLayer layer];
            sl.name = @"shape";
            sl.contentsScale = [UIScreen mainScreen].scale;
            sl.lineWidth = self.lineWidth;
            sl.path = self.shapePath.CGPath;
            sl.strokeColor = self.color.CGColor;
            sl.fillColor = [UIColor clearColor].CGColor;
            [layers addObject:sl];
            
            [self.shapePath addLineToPoint:self.closePoint];
            [self.shapePath addLineToPoint:self.closeStartPoint];
            [self.shapePath closePath];
            [self.shapePath addClip];
            
            CAGradientLayer *gradientLayer = [CAGradientLayer layer];
            gradientLayer.name = @"gradient";
            gradientLayer.contentsScale = [UIScreen mainScreen].scale;
            gradientLayer.colors = @[(id)[self.fillColor colorWithAlphaComponent:.6].CGColor, (id)[self.fillColor colorWithAlphaComponent:0.3].CGColor, (id)[self.fillColor colorWithAlphaComponent:0.0].CGColor];
            gradientLayer.locations = @[@0.0, @0.3, @1];
            
            CGRect pathRect = CGPathGetBoundingBox(self.shapePath.CGPath);
            gradientLayer.startPoint = CGPointMake(0.5, 0);
            gradientLayer.endPoint = CGPointMake(0.5, 1);
            gradientLayer.frame = pathRect;
            
            [path applyTransform:CGAffineTransformMakeTranslation(0, -pathRect.origin.y)];
            shapeLayer.path = path.CGPath;
            gradientLayer.mask = shapeLayer;
            [layers addObject:gradientLayer];
        }
    }
    _layers = [layers copy];
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGContextSaveGState(ctx);
    
    if (self.shapePath) {
        CGContextAddPath(ctx, self.shapePath.CGPath);
    } else {
        if (!CGRectIsNull(self.frame) && !CGRectIsEmpty(self.frame)) {
            CGRect frame;
            if (CGRectGetWidth(self.frame)<self.lineWidth*2) {
                frame = CGRectOffset(self.frame, self.lineWidth, self.lineWidth);
                frame.size.width = self.lineWidth;
            } else {
                frame = CGRectInset(self.frame, self.lineWidth, self.lineWidth);
            }
            CGContextAddRect(ctx, frame);
        }
    }
    
    CGContextSetLineWidth(ctx, self.lineWidth);
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    
    CGContextSetStrokeColorWithColor(ctx, self.color.CGColor);
    
    if (!self.needClose) {
        switch (self.drawType) {
            case YJShapDrawTypeFill:
                CGContextDrawPath(ctx, kCGPathFill);
                break;
            case YJShapDrawTypeStroke:
                CGContextDrawPath(ctx, kCGPathStroke);
                break;
            default:
                CGContextDrawPath(ctx, kCGPathFillStroke);
                break;
        }
    } else {
        CGContextDrawPath(ctx, kCGPathStroke);
    }
    
    CGContextRestoreGState(ctx);
    
    [self closePathInContext:ctx];
}

- (void)closePathInContext:(CGContextRef)ctx
{
    if (!self.shapePath || !self.needClose) return;
    
    CGContextSaveGState(ctx);
    
    UIBezierPath *path = [self.shapePath copy];
    
    [path addLineToPoint:self.closePoint];
    [path addLineToPoint:self.closeStartPoint];
    [path closePath];
    [path addClip];
    
    CGContextAddPath(ctx, path.CGPath);
    
    CGContextSetLineWidth(ctx, self.lineWidth);
    [self fillColorInContext:ctx forPath:path];
    CGContextSetStrokeColorWithColor(ctx, self.closeLineColor.CGColor);
    
    switch (self.drawType) {
        case YJShapDrawTypeFill:
            CGContextDrawPath(ctx, kCGPathFill);
            break;
        case YJShapDrawTypeStroke:
            CGContextDrawPath(ctx, kCGPathStroke);
            break;
        default:
            CGContextDrawPath(ctx, kCGPathFillStroke);
            break;
    }
    
    CGContextRestoreGState(ctx);
}

- (void)fillColorInContext:(CGContextRef)ctx forPath:(UIBezierPath *)path
{
    if (!self.gradient) {
        CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
        return;
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGFloat red = 0, green = 0, blue = 0, alpha = 1;
    [self.fillColor getRed:&red green:&green blue:&blue alpha:&alpha];
    
    const CGFloat components[] = {red, green, blue, .6, red, green, blue, .3, red, green, blue, 0};
    const CGFloat locations[] = {0., .3, 1.};
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, 3);
    CGRect pathRect = CGPathGetPathBoundingBox(path.CGPath);
    CGPoint startPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMinY(pathRect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(pathRect), CGRectGetMaxY(pathRect));
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

@end
