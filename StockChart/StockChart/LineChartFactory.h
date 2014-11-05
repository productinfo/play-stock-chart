//
//  LineChartFactory.h
//  ShinobiControls
//
//  Created by Sam Davies on 16/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShinobiCharts/ShinobiCharts.h>

@interface LineChartFactory : NSObject

+ (id<SChartDatasource>)createChartDatasource;

+ (ShinobiChart*)createChartWithBounds:(CGRect)bounds dataSource:(id<SChartDatasource>)datasource;

@end
