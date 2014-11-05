//
//  FinancialChartDataSource.h
//  ShinobiControls
//
//  Created by Sam Davies on 16/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiCharts.h>
#import "StockChartData.h"
#import "SChartDatasourceLookup.h"

@interface FinancialChartDataSource : NSObject <SChartDatasource, SChartDatasourceLookup>

@property (nonatomic, strong) StockChartData *chartData;

@end
