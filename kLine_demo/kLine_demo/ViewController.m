//
//  ViewController.m
//  kLine_demo
//
//  Created by 张永俊 on 2017/11/30.
//  Copyright © 2017年 张永俊. All rights reserved.
//

#import "ViewController.h"
#import "StockView.h"
#import "YJHelper.h"

@interface ViewController ()

@property (nonatomic, strong) StockView *stockView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    StockView *stockView = [[StockView alloc] initWithFrame:self.view.bounds];
    stockView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:stockView];
    self.stockView = stockView;
    
    stockView.chJsCode = @"000001";
    
    NSString *klinePath = [[NSBundle mainBundle] pathForResource:@"kline.json" ofType:nil];
    id klineJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:klinePath] options:0 error:nil];
    
    NSString *levelPath = [[NSBundle mainBundle] pathForResource:@"level.json" ofType:nil];
    id levelJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:levelPath] options:0 error:nil];
    
    NSString *flucPath = [[NSBundle mainBundle] pathForResource:@"stock.json" ofType:nil];
    id flucJson = [NSJSONSerialization JSONObjectWithData:[NSData dataWithContentsOfFile:flucPath] options:0 error:nil];
    
    __weak typeof(stockView) weakSW = stockView;
    //刷新
    [stockView setOnRightRefresh:^(NSDictionary *p) {
        YJStockType type = [YJHelper stockTypeFromBridge:p[YJStockViewTypeKey]];
        [weakSW refresh:[klineJson objectForKey:@"lineDatas"] type:type];
        
        if (type == YJStockTypeEachMinute || type == YJStockTypeFiveDay) {
            [weakSW level:[levelJson objectForKey:@"levels"]];
        }
    }];
    //加载更多
    [stockView setOnLeftRefresh:^(NSDictionary *p) {
        [weakSW append:[klineJson objectForKey:@"lineDatas"] type:[YJHelper stockTypeFromBridge:p[YJStockViewTypeKey]]];
    }];
    
    [stockView fluc:flucJson[@"targets"][0]];
    [stockView selectType:YJStockTypeEachMinute];
}


@end
