//
//  YJDrawerView.m
//  KLine
//
//  Created by 张永俊 on 2017/9/25.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "YJDrawerView.h"
#import "CALayer+YJExtension.h"

@interface YJDrawerView()
{
    struct {
        unsigned int knowBeginDraw: 1;
        unsigned int knowEndDraw: 1;
    } _delegates;
}

@property (nonatomic, strong) NSMutableArray<id<YJDrawer>> *drawers;
@property (nonatomic, strong) NSMutableArray<id<YJDrawer>> *presents;

@property (nonatomic, strong) NSMutableArray<CALayer *> *layers;

@end

@implementation YJDrawerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (NSMutableArray<id<YJDrawer>> *)presents
{
    if (!_presents) {
        _presents = [NSMutableArray array];
    }
    return _presents;
}

- (NSMutableArray<id<YJDrawer>> *)drawers
{
    if (!_drawers) {
        _drawers = [NSMutableArray array];
    }
    return _drawers;
}

- (NSMutableArray<CALayer *> *)layers
{
    if (!_layers) {
        _layers = [NSMutableArray array];
    }
    return _layers;
}

- (void)setup
{
    self.backgroundColor = [UIColor clearColor];
}

- (void)removeDrawerToPresent:(id<YJDrawer>)drawer
{
    if ([self.presents containsObject:drawer]) {
        NSMutableArray *tmpLayers = [NSMutableArray array];
        [self.layers enumerateObjectsUsingBlock:^(CALayer * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.weakObj isEqual:drawer]) {
                [tmpLayers addObject:obj];
                [obj removeFromSuperlayer];
            }
        }];
        [self.layers removeObjectsInArray:tmpLayers];
        [self.presents removeObject:drawer];
    }
}

- (void)addOrUpdateDrawerToPresent:(id<YJDrawer>)drawer
{
    [self removeDrawerToPresent:drawer];
    
    [self.presents addObject:drawer];
    
    for (CALayer *layer in drawer.layers) {
        layer.weakObj = drawer;
        [self.layer addSublayer:layer];
        [self.layers addObject:layer];
    }
    if (self.animateLayers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.animateLayers(self.layers);
        });
    }
}

- (void)representWithDrawers:(NSArray<id<YJDrawer>> *)drawer, ...
{
    NSMutableArray *drawers = [NSMutableArray array];
    if (drawer) {
        [drawers addObjectsFromArray:drawer];
        va_list args;
        
        NSArray *arg;
        va_start(args, drawer);
        
        while ((arg = va_arg(args, NSArray<id<YJDrawer>> *))) {
            [drawers addObjectsFromArray:arg];
        }
        va_end(args);
    }
    self.presents = drawers;
    [self.layers makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    NSMutableArray *layers = [NSMutableArray array];
    for (id<YJDrawer> drawer in drawers) {
        for (CALayer *layer in drawer.layers) {
            layer.weakObj = drawer;
            [self.layer addSublayer:layer];
            [layers addObject:layer];
        }
    }
    self.layers = layers;
    if (self.animateLayers) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.animateLayers(self.layers);
        });
    }
}

- (void)redrawWithDrawers:(NSArray<id<YJDrawer>> *)drawer, ...
{
    NSMutableArray *drawers = [NSMutableArray array];
    if (drawer) {
        [drawers addObjectsFromArray:drawer];
        va_list args;

        NSArray *arg;
        va_start(args, drawer);

        while ((arg = va_arg(args, NSArray<id<YJDrawer>> *))) {
            [drawers addObjectsFromArray:arg];
        }
        va_end(args);
    }
    self.drawers = drawers;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (!self.drawers || self.drawers.count == 0) return;

    if (_delegates.knowBeginDraw) {
        if (![self.delegate drawerViewShouldBeginDraw:self]) return;
    }

    CGContextRef ctx = UIGraphicsGetCurrentContext();
    for (id<YJDrawer> drawer in self.drawers) {
        [drawer drawInContext:ctx];
    }

    if (_delegates.knowEndDraw)
        [self.delegate drawerViewDidEndDraw:self];
}

- (void)setDelegate:(id<YJDrawerViewDelegate>)delegate
{
    _delegate = delegate;
    _delegates.knowBeginDraw = [delegate respondsToSelector:@selector(drawerViewShouldBeginDraw:)];
    _delegates.knowEndDraw = [delegate respondsToSelector:@selector(drawerViewDidEndDraw:)];
}

@end
