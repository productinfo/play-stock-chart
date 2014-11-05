//
//  FinancialChartData.h
//  ShinobiControls
//
//  Created by  on 17/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSInteger const StockChartMovingAverageNPeriod;

@interface StockChartData : NSObject

@property (nonatomic, strong) NSMutableArray *seriesOpen;
@property (nonatomic, strong) NSMutableArray *seriesHigh;
@property (nonatomic, strong) NSMutableArray *seriesLow;
@property (nonatomic, strong) NSMutableArray *seriesClose;
@property (nonatomic, strong) NSMutableArray *volume;
@property (nonatomic, strong) NSMutableArray *dates;

+ (StockChartData*)getInstance;

- (NSNumber *)movingAverageValueForIndex:(NSUInteger)index;
- (NSNumber *)lowerBollingerValueForIndex:(NSUInteger)index;
- (NSNumber *)upperBollingerValueForIndex:(NSUInteger)index;
- (NSUInteger)numberOfDataPoints;

//- (NSNumber *)sampledMinInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx;
//- (NSNumber *)sampledMaxInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx;

@end
