//
//  StockChartValueAnnotationManager.m
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
#import <ShinobiCharts/ShinobiChart.h>
#import "StockChartDatasourceLookup.h"

/**
 Class to add an annotation to the chart with a dashed line and label showing the value at
 the last point displayed.
 To use this class, you should call updateValueAnnotationForXAxisRangeLyAxisRange: whenever
 the chart's range changes.
 There's a detailed tutorial on how to create a similar value annotation at:
 http://www.shinobicontrols.com/blog/posts/2013/05/building-a-range-selector-with-shinobicharts-part-iv
 */
@interface StockChartValueAnnotationManager : NSObject

- (instancetype)initWithChart:(ShinobiChart *)chart datasource:(id<StockChartDatasourceLookup>)datasource
                  seriesIndex:(NSInteger)seriesIndex;

// Updates the value annotation based on the given ranges, and redraws the chart
- (void)updateValueAnnotationForXAxisRange:(SChartRange *)xRange yAxisRange:(SChartRange *)yRange;

// Updates the value annotation based on the given ranges, with optional redraw
- (void)updateValueAnnotationForXAxisRange:(SChartRange *)xRange yAxisRange:(SChartRange *)yRange
                                    redraw:(BOOL)redraw;

@end
