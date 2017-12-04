//
//  YJTextDrawer.m
//  KLine
//
//  Created by 张永俊 on 2017/9/27.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJTextDrawer.h"

@implementation YJTextDrawer

- (instancetype)init
{
    self = [super init];
    if (self) {
        _frame = CGRectNull;
    }
    return self;
}

- (CGRect)frame
{
    if (CGRectIsEmpty(_frame)) {
        _frame = (CGRect){CGPointZero, [self.text sizeWithAttributes:self.attributes]};
    }
    return _frame;
}

- (void)setText:(NSString *)text
{
    if (![_text isEqualToString:text]) {
        self.frame = CGRectNull;
    }
    _text = text;
}

- (void)setAttributes:(NSDictionary *)attributes
{
    if (_attributes) {
        UIFont *f = _attributes[NSFontAttributeName];
        UIFont *f2 = attributes[NSFontAttributeName];
        if (f.lineHeight != f2.lineHeight) {
            self.frame = CGRectNull;
        }
    }
    _attributes = attributes;
}

- (void)fixFrameWithMaxWidth:(CGFloat)maxWidth maxEdgeY:(CGFloat)maxEdgeY minEdgeY:(CGFloat)minEdgeY centerY:(CGFloat)centerY alignment:(NSTextAlignment)alignment
{
    if (!self.attributes[NSForegroundColorAttributeName]) return;
    if (CGRectGetWidth(self.frame) > maxWidth) {
        self.frame = CGRectZero;
    }
    CGFloat x = alignment == NSTextAlignmentRight ? maxWidth - CGRectGetWidth(self.frame) : 0;
    CGFloat y = centerY - CGRectGetHeight(self.frame) * 0.5;
    
    if (y < minEdgeY) {
        y = minEdgeY;
    } else if (y + CGRectGetHeight(self.frame) > maxEdgeY) {
        y = maxEdgeY - CGRectGetHeight(self.frame);
    }
    
    self.frame = (CGRect){{x, y}, self.frame.size};
}

- (void)fixFrameWithMaxEdgeX:(CGFloat)maxEdgeX minEdgeX:(CGFloat)minEdgeX centerX:(CGFloat)centerX centerY:(CGFloat)centerY
{
    if (!self.attributes[NSForegroundColorAttributeName]) return;
    CGFloat y = centerY - CGRectGetHeight(self.frame) * 0.5;
    CGFloat x = centerX - CGRectGetWidth(self.frame) * 0.5;
    
    if (x < minEdgeX) {
        x = minEdgeX;
    } else if (x + CGRectGetWidth(self.frame) > maxEdgeX) {
        x = maxEdgeX - CGRectGetWidth(self.frame);
    }
    
    self.frame = (CGRect){{x, y}, self.frame.size};
}

- (void)resetLayers
{
    NSMutableArray *layers = [NSMutableArray array];
    
    CATextLayer *layer = [CATextLayer layer];
    layer.name = @"text";
    layer.fontSize = [(UIFont *)self.attributes[NSFontAttributeName] pointSize];
    layer.font = (__bridge CFTypeRef _Nullable)([(UIFont *)self.attributes[NSFontAttributeName] fontName]);
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.foregroundColor = [(UIColor *)self.attributes[NSForegroundColorAttributeName] CGColor];
    layer.backgroundColor = [(UIColor *)self.attributes[NSBackgroundColorAttributeName] CGColor];
    layer.string = self.text;
    layer.frame = self.frame;
    
    [layers addObject:layer];
    
    _layers = [layers copy];
}

- (void)drawInContext:(CGContextRef)ctx
{
    [self.text drawInRect:self.frame withAttributes:self.attributes];
}

@end
