//
//  RangeChartDataSource.h
//  ShinobiControls
//
//  Created by  on 17/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiCharts.h>
#import "StockChartData.h"

@interface RangeChartDataSource : NSObject<SChartDatasource>

@property (nonatomic, strong) StockChartData *chartData;

@end
