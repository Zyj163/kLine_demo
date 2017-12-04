//
//  StockView.m
//  myJsApp
//
//  Created by 张永俊 on 2017/10/11.
//  Copyright © 2017年 Facebook. All rights reserved.
//

#import "StockView.h"
#import "PortraitStockTitleView.h"
#import "YJKLineView.h"
#import "YJTrendView.h"
#import "StockTabView.h"

#import "StockViewController.h"
#import "YJHelper.h"
#import "ViewModelConnector.h"

#import "WuDangInfoView.h"
#import "YJLevelInfoModel.h"

#import "YJTab.h"
#import "YJTabViews.h"

#define kTopTitleViewMarginBottom 5.
#define kStockTabH 40.
#define kLineViewH (225.+20.+47.)
#define kRightInfoTabH 37.

@interface StockView() <YJStockViewableDelegate>

@property (nonatomic, weak) UIView *topTitleView;

@property (nonatomic, strong) UIView<YJStockViewable> *mainView;
@property (nonatomic, strong) YJTabViews *tabViews;

@property (nonatomic, strong) YJTabViews *rightInfoTabViews;

@property (nonatomic, strong) WuDangInfoView *wudangInfoView;

@property (nonatomic, strong) PortraitStockTitleView *portraitTitleView;
@property (nonatomic, strong) StockTabView *stockTabView;

@property (nonatomic, weak) StockViewController *stockVc;

@property (nonatomic, assign) CGFloat topTitleViewH;

@property (nonatomic, assign) CGFloat currentHeight;

@property (nonatomic, assign) CGRect preBounds;

@property (nonatomic, strong) NSCache<NSValue *, NSMutableArray<YJStockModel *> *> *allStocks;
@property (nonatomic, strong) NSMutableDictionary<NSValue *, YJDrawerConnector *> *connectors;

@property (nonatomic, copy) NSArray<YJLevelInfoModel *> *levels;

@property (nonatomic, strong) dispatch_queue_t klineQueue;

@property (nonatomic, assign) BOOL titleViewHidden;

@property (nonatomic, assign) CFRunLoopObserverRef observer;

@end

@implementation StockView

#pragma mark - property
- (NSCache<NSValue *,NSMutableArray<YJStockModel *> *> *)allStocks
{
    if (!_allStocks) {
        _allStocks = [NSCache new];
    }
    return _allStocks;
}

- (NSMutableDictionary<NSValue *,YJDrawerConnector *> *)connectors
{
    if (!_connectors) {
        _connectors = [NSMutableDictionary dictionary];
    }
    return _connectors;
}

- (WuDangInfoView *)wudangInfoView
{
    if (!_wudangInfoView) {
        _wudangInfoView = [WuDangInfoView new];
    }
    return _wudangInfoView;
}

- (StockTabView *)stockTabView
{
    if (!_stockTabView) {
        _stockTabView = [StockTabView new];
        [self addSubview:_stockTabView];
        __weak typeof(self) ws = self;
        [_stockTabView setHeightChange:^(CGFloat height) {
            [ws setNeedsLayout];
            [ws layoutIfNeeded];
        }];
    }
    return _stockTabView;
}

- (PortraitStockTitleView *)portraitTitleView
{
    if (!_portraitTitleView) {
        _portraitTitleView = [PortraitStockTitleView portraitView];
        [self addSubview:_portraitTitleView];
    }
    return _portraitTitleView;
}

- (YJTabViews *)rightInfoTabViews
{
    if (!_rightInfoTabViews) {
        YJTab *rightInfoTab = [YJTab new];
        YJHelper *helper = [YJHelper sharedHelper];
        rightInfoTab.backgroundColor = helper.color5;
        rightInfoTab.normalTitleColor = helper.color3;
        rightInfoTab.selectedTitleColor = helper.color6;
        rightInfoTab.titleFont = helper.fontE;
        
        YJTabViews *rightInfoTabViews = [YJTabViews new];
        _rightInfoTabViews = rightInfoTabViews;
        __weak typeof(self) ws = self;
        [rightInfoTabViews installTab:rightInfoTab withTitles:@[@"五档", @"成交"] tabH:kRightInfoTabH position:YJTabViewsTabPositionTop contents:^UIView *(NSInteger preIdx, NSInteger idx) {
            return ws.wudangInfoView;
        }];
        [self addSubview:_rightInfoTabViews];
    }
    return _rightInfoTabViews;
}

- (void)setChJsCode:(NSString *)chJsCode
{
    dispatch_sync(self.klineQueue, ^{
        if (_chJsCode && ![chJsCode isEqualToString:_chJsCode]) {
            [self resetAllStocks];
        }
    });
    
    _chJsCode = chJsCode;
}

#pragma mark - override method
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [YJHelper sharedHelper].backgroundColor;
        self.clipsToBounds = YES;
        
        [self setup];
        
        [self addObservers];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [self.topTitleView setFrame:(CGRect){0, 0, CGRectGetWidth(self.bounds), self.topTitleViewH}];
    
    [self.tabViews setFrame:(CGRect){0, self.topTitleViewH+kTopTitleViewMarginBottom, CGRectGetWidth(self.bounds), kStockTabH+kLineViewH}];
    
    [self.stockTabView setFrame:(CGRect){0, CGRectGetMaxY(self.tabViews.frame), CGRectGetWidth(self.bounds), CGRectGetHeight(_stockTabView.bounds)}];
    
    if (self.onHeightChange) {
        self.onHeightChange(@{@"height": @(self.topTitleViewH+kTopTitleViewMarginBottom+kLineViewH+kStockTabH+CGRectGetHeight(_stockTabView.bounds))});
    }
    
    CGFloat marginH = 5.;
    CGFloat rightViewW = CGRectGetWidth(self.bounds)*(375.-270.-marginH*3-1.)/375.;
    CGFloat x = CGRectGetWidth(self.bounds) - rightViewW - marginH;
    
    [_rightInfoTabViews setFrame:(CGRect){x, CGRectGetMinY(self.tabViews.frame), rightViewW, CGRectGetHeight(self.tabViews.frame)-kStockTabH}];
}

- (void)dealloc
{
    [self removeObservers];
}

#pragma mark - private method
- (void)setup
{
    YJHelper *helper = [YJHelper sharedHelper];
    
    self.klineQueue = dispatch_queue_create([self.description UTF8String], 0);
    self.topTitleView = self.portraitTitleView;
    self.topTitleViewH = 107;
    [self addSubview:self.topTitleView];
    
    NSArray *titles = @[@"分时", @"5日", @"日K", @"周K", @"月K", @"分钟"];
    NSArray *types = [self stockTypes];
    
    YJTab *tab = [YJTab new];
    tab.backgroundColor = helper.color5;
    tab.normalTitleColor = helper.color3;
    tab.selectedTitleColor = helper.color6;
    tab.titleFont = helper.fontC;
    tab.specifyPaddingH = 15.;
    
    __weak typeof(self) ws = self;
    YJTabViews *tabViews = [YJTabViews new];
    tabViews.backgroundColor = helper.color5;
    self.tabViews = tabViews;
    [self addSubview:tabViews];
    [tabViews installTab:tab withTitles:titles tabH:kStockTabH position:YJTabViewsTabPositionBottom contents:^UIView *(NSInteger preIdx, NSInteger idx) {
        YJStockType type = [types[idx] integerValue];
        if (type == YJStockTypeEachMinute || type == YJStockTypeFiveDay) {
            ws.rightInfoTabViews.hidden = NO;
            CGFloat marginH = 5.;
            CGFloat rightViewW = [UIScreen mainScreen].bounds.size.width*(375.-270.-marginH*3-1.)/375.;
            tabViews.specifyContentsInset = UIEdgeInsetsMake(0, 5, 0, rightViewW+marginH*2+1.);
        } else {
            ws.rightInfoTabViews.hidden = YES;
            tabViews.specifyContentsInset = UIEdgeInsetsZero;
        }
        
        UIView<YJStockViewable> *mainView = [ws realViewForType:type];
        
        mainView.connector = [ws connectorForType:type useOnce:NO];
        
        NSMutableArray *datas = [self stocksForType:type];
        mainView.datas = datas;
        
        ws.mainView = mainView;
        if (datas.count == 0) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.mainView showHUD];
                [ws fetchDatas:0 type:type];
            });
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [ws.mainView showHUD];
                [ws.mainView drawWithCompletionHandler:^{
                    [ws.mainView hideHUD];
                }];
            });
        }
        if (ws.onStockTypeChange) {
            ws.onStockTypeChange(@{YJStockViewTypeKey: [YJHelper bridgeStockForType:self.mainView.connector.stockType]});
        }
        return mainView;
    }];
}

- (void)addObservers
{
    __weak typeof(self) ws = self;
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, kCFRunLoopBeforeWaiting, true, -1, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        if (!ws.onOriginChange) return ;
        CGPoint titleViewOrigin = [ws.portraitTitleView convertPoint:ws.portraitTitleView.frame.origin toView:nil];
        if (!ws.titleViewHidden && titleViewOrigin.y <= ws.originChangeValue) {
            ws.titleViewHidden = YES;
            ws.onOriginChange(@{@"value": @(titleViewOrigin.y)});
        } else if (ws.titleViewHidden && titleViewOrigin.y > ws.originChangeValue) {
            ws.titleViewHidden = NO;
            ws.onOriginChange(@{@"value": @(titleViewOrigin.y)});
        }
    });
    CFStringRef str = (__bridge CFStringRef)UITrackingRunLoopMode;
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, str);
    self.observer = observer;
    CFRelease(observer);
    CFBridgingRelease(str);
}

- (void)removeObservers
{
    CFStringRef str = (__bridge CFStringRef)UITrackingRunLoopMode;
    CFRunLoopRemoveObserver(CFRunLoopGetCurrent(), self.observer, str);
    CFBridgingRelease(str);
}

- (NSMutableArray *)stocksForType:(YJStockType)type
{
    NSMutableArray *datas = [self.allStocks objectForKey:@(type)];
    if (!datas) {
        datas = [NSMutableArray array];
        [self.allStocks setObject:datas forKey:@(type)];
    }
    return datas;
}

- (void)resetAllStocks
{
    [[self MATypes] enumerateObjectsUsingBlock:^(NSNumber * _Nonnull type, NSUInteger idx, BOOL * _Nonnull stop) {
        NSMutableArray *arr = [self.allStocks objectForKey:type];
        [arr removeAllObjects];
    }];
    [self.allStocks removeAllObjects];
}

- (void)preDealWithDatas:(NSArray<YJStockModel *> *)stocks forType:(YJStockType)type
{
    switch (type) {
        case YJStockTypeNone:
        case YJStockTypeFiveDay:
        case YJStockTypeEachMinute:
            break;
            
        default:
            [YJHelper prePrepareAVGs:stocks counts:self.MATypes];
            break;
    }
}

- (BOOL)updateBy:(YJStockModel *)stock forType:(YJStockType)type
{
    NSMutableArray *datas = [self stocksForType:type];
    if (!datas || datas.count == 0) return NO;
    YJStockModel *lastStock = datas.lastObject;
    __block BOOL needRefresh = NO;
    void(^update)(void) = ^{
        [datas replaceObjectAtIndex:datas.count-1 withObject:stock];
        needRefresh = YES;
    };
    void(^append)(void) = ^{
        [datas addObject:stock];
        needRefresh = YES;
    };
    void(^reset)(void) = ^{
        [datas removeAllObjects];
        needRefresh = YES;
    };
    switch (type) {
        case YJStockTypeMinute:
            [YJHelper compareMinute:lastStock and:stock cirticalValue:11 minute:30 newHour:13 newMinute:0 ifUpdate:update ifAppend:append ifReset:reset];
            break;
        case YJStockTypeFiveDay:
            [YJHelper compareFiveDayMinute:lastStock and:stock cirticalValueInSameDay:11 minute:30 newHour:13 newMinute:0 nextDayTodayHour:15 todayMinute:0 nextDayHour:9 nextDayMinute:0 ifUpdate:update ifAppend:append ifReset:reset];
            break;
        case YJStockTypeDay:
            [YJHelper compareDay:lastStock and:stock ifUpdate:update ifAppend:append ifReset:reset];
            break;
        case YJStockTypeWeek:
            [YJHelper compareWeek:lastStock and:stock ifUpdate:update ifAppend:append ifReset:reset];
            break;
            
        default:
            break;
    }
    
    return needRefresh;
}

- (void)fetchDatas:(NSUInteger)idx type:(YJStockType)type
{
    if (idx == 0) {
        self.mainView.rightRefreshing = YES;
    } else {
        self.mainView.leftRefreshing = YES;
    }
}

- (NSArray *)stockTypes
{
    return @[@(YJStockTypeEachMinute), @(YJStockTypeFiveDay), @(YJStockTypeDay), @(YJStockTypeWeek), @(YJStockTypeMonth), @(YJStockTypeMinute)];
}

- (NSArray *)MATypes
{
    return @[@5, @10, @20, @30];
}

- (YJDrawerConnector *)connectorForType:(YJStockType)type useOnce:(BOOL)useOnce
{
    YJDrawerConnector *connector = [self.connectors objectForKey:@(type)];
    if (connector) return connector;
    switch (type) {
        case YJStockTypeEachMinute:
        case YJStockTypeFiveDay:
        {
            connector = [YJTrendDrawerConnector new];
        }
            break;
            
        case YJStockTypeDay:
        case YJStockTypeWeek:
        case YJStockTypeMonth:
        default:
        {
            YJKLineDrawerConnector *klineConnector = [YJKLineDrawerConnector new];
            klineConnector.candleCount = [klineConnector suggestCandleCountInRect:[UIScreen mainScreen].bounds withScale:1];
            klineConnector.MATypes = self.MATypes;
            connector = klineConnector;
        }
            break;
    }
    if (!useOnce) {
        self.connectors[@(type)] = connector;
    }
    connector.stockType = type;
    return connector;
}

- (UIView<YJStockViewable> *)realViewForType:(YJStockType)type
{
    UIView<YJStockViewable> *mainView;
    switch (type) {
        case YJStockTypeEachMinute:
        case YJStockTypeFiveDay:
        {
            mainView = [YJTrendView new];
        }
            break;
            
        case YJStockTypeDay:
        case YJStockTypeWeek:
        case YJStockTypeMonth:
        default:
        {
            mainView = [YJKLineView new];
        }
            break;
    }
    mainView.prepareQueue = self.klineQueue;
    mainView.delegate = self;
    return mainView;
}

- (void)setupStockVCForType:(YJStockType)type
{
    StockViewController *vc = [[StockViewController alloc] init];
    self.stockVc = vc;
    UIView<YJStockViewable> *launchView = [self realViewForType:type];
    vc.mainView = launchView;
    launchView.datas = self.mainView.datas;
    YJKLineDrawerConnector *connector = (YJKLineDrawerConnector *)[self connectorForType:type useOnce:YES];
    launchView.connector = connector;
    [yj_getCurrentVC(nil) presentViewController:vc animated:NO completion:nil];
}


#pragma mark - YJStockViewableDelegate
- (void)stockViewBeginRightRefresh:(UIView<YJStockViewable> *)stockView
{
    if (!self.onRightRefresh) return;
    NSMutableDictionary *params = @{YJStockViewTypeKey: [YJHelper bridgeStockForType:self.mainView.connector.stockType]}.mutableCopy;
    if ([stockView isKindOfClass:[YJKLineView class]]) {
        YJKLineView *klineView = (YJKLineView *)stockView;
        params[@"count"] = @(klineView.connector.candleCount * 2);
    }
    self.onRightRefresh(params);
}

- (void)stockViewBeginLeftRefresh:(UIView<YJStockViewable> *)stockView
{
    if (!self.onLeftRefresh) return;
    YJKLineView *klineView = (YJKLineView *)stockView;
    if (!klineView.datas || klineView.datas.count == 0) return;
    self.onLeftRefresh(@{
                          YJStockViewTypeKey: [YJHelper bridgeStockForType:self.mainView.connector.stockType],
                          @"count": @(klineView.connector.candleCount * 2),
                          @"time": klineView.datas.lastObject.time
                          });
}

- (void)stockView:(UIView<YJStockViewable> *)stockView beTapedOn:(CGPoint)location
{
    if ([stockView isEqual:self.stockVc.mainView]) {
        [self.stockVc dismissViewControllerAnimated:NO completion:^{
            if ([stockView respondsToSelector:@selector(resetAnimateCircle)]) {
                [stockView performSelector:@selector(resetAnimateCircle)];
            }
        }];
    } else {
        [self setupStockVCForType:stockView.connector.stockType];
    }
}


#pragma mark - public method

- (void)selectType:(YJStockType)type
{
    [[self stockTypes] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (type == [obj integerValue]) {
            [self.tabViews.tab setSelected:idx];
            *stop = YES;
        }
    }];
}

- (void)refresh:(id)json type:(YJStockType)type
{
    if (!json) return;
    dispatch_async(self.klineQueue, ^{
        NSArray *newDatas = [NSArray yy_modelArrayWithClass:[YJStockModel class] json:json];
        if (!newDatas || newDatas.count == 0) {}
        else {
            NSMutableArray *datas = [self stocksForType:type];
            [datas removeAllObjects];
            [datas addObjectsFromArray:newDatas];
            [self preDealWithDatas:datas forType:type];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!self.stockVc) {
                if (type == self.mainView.connector.stockType) {
                    self.mainView.hidden = NO;
                    [self.mainView drawWithCompletionHandler:^{
                        [self.mainView hideHUD];
                    }];
                    self.mainView.rightRefreshing = NO;
                }
            } else {
                if (type == self.stockVc.mainView.connector.stockType) {
                    self.stockVc.mainView.rightRefreshing = NO;
                    [self.stockVc.mainView drawWithCompletionHandler:^{
                        [self.stockVc.mainView hideHUD];
                    }];
                }
            }
        });
    });
}

- (void)append:(id)json type:(YJStockType)type
{
    if (!json) return;
    dispatch_async(self.klineQueue, ^{
        NSArray *newDatas = [NSArray yy_modelArrayWithClass:[YJStockModel class] json:json];
        if (!newDatas || newDatas.count == 0) {}
        else {
            NSMutableArray *datas = [self stocksForType:type];
            [datas addObjectsFromArray:newDatas];
            [self preDealWithDatas:datas forType:type];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!self.stockVc) {
                if (type == self.mainView.connector.stockType) {
                    [self.mainView draw];
                    self.mainView.leftRefreshing = NO;
                }
            } else {
                if (type == self.stockVc.mainView.connector.stockType) {
                    [self.stockVc.mainView draw];
                    self.stockVc.mainView.leftRefreshing = NO;
                }
            }
        });
    });
}

- (void)insert:(id)json type:(YJStockType)type
{
    if (!json) return;
    dispatch_async(self.klineQueue, ^{
        NSArray *newDatas = [NSArray yy_modelArrayWithClass:[YJStockModel class] json:json];
        if (!newDatas || newDatas.count == 0) {}
        else {
            NSMutableArray *datas = [self stocksForType:type];
            NSArray *insertDatas = newDatas;
            NSIndexSet *set = [NSIndexSet indexSetWithIndexesInRange:(NSRange){0, insertDatas.count}];
            
            [datas insertObjects:insertDatas atIndexes:set];
            
            [self preDealWithDatas:datas forType:type];
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!self.stockVc) {
                if (type == self.mainView.connector.stockType) {
                    [self.mainView draw];
                }
            } else {
                if (type == self.stockVc.mainView.connector.stockType) {
                    [self.stockVc.mainView draw];
                }
            }
        });
    });
}

- (void)fluc:(id)json
{
    if (!json) return;
    dispatch_async(self.klineQueue, ^{
        YJStockModel *fluc = [YJStockModel yy_modelWithJSON:json];
        //调整缓冲数据
        BOOL needRefresh = NO;
        YJStockType curType = self.mainView.connector.stockType;
        if ([self updateBy:fluc forType:YJStockTypeMinute] && curType == YJStockTypeEachMinute) {
            needRefresh = YES;
        }
        if ([self updateBy:fluc forType:YJStockTypeFiveDay] && curType == YJStockTypeFiveDay) {
            needRefresh = YES;
        }
        if ([self updateBy:fluc forType:YJStockTypeDay] && curType == YJStockTypeDay) {
            needRefresh = YES;
        }
        if ([self updateBy:fluc forType:YJStockTypeWeek] && curType == YJStockTypeWeek) {
            needRefresh = YES;
        }
        
        dispatch_sync(dispatch_get_main_queue(), ^{
            if (!self.stockVc) {
                [ViewModelConnector connectorPortraitStockTitleView:self.portraitTitleView withStock:fluc];
                
                [ViewModelConnector connectorStockTabView:self.stockTabView withStock:fluc];
                //刷新当前展示数据
                if (needRefresh) {
                    NSArray *datas = [self stocksForType:self.mainView.connector.stockType];
                    if (datas.count == 0) {
                        [self fetchDatas:0 type:self.mainView.connector.stockType];
                    } else {
                        [self.mainView draw];
                    }
                }
            } else {
                
            }
        });
    });
}

- (void)level:(id)json
{
    if (!json) return;
    dispatch_async(self.klineQueue, ^{
        self.levels = [NSArray yy_modelArrayWithClass:[YJLevelInfoModel class] json:json];
        dispatch_sync(dispatch_get_main_queue(), ^{
            [self.rightInfoTabViews.tab setSelected:0];
            dispatch_async(dispatch_get_main_queue(), ^{
                [ViewModelConnector connectorLevelInfo:self.wudangInfoView withLevels:self.levels curP:self.portraitTitleView.mainTitleLabel.text.doubleValue];
            });
        });
    });
}

@end
