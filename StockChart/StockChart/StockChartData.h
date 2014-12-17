//
//  StockChartData.h
//  StockChart
//
//  Created by Alison Clarke on 27/08/2014.
//
//  Copyright 2014 Scott Logic
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <Foundation/Foundation.h>

static NSInteger const StockChartMovingAverageNPeriod = 20;

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

- (NSNumber *)sampledMinInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx;
- (NSNumber *)sampledMaxInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx;

@end
