//
//  LineChartFactory.m
//  ShinobiControls
//
//  Created by Sam Davies on 16/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "StockChartLineChartFactory.h"
#import "StockChartDataSource.h"

@implementation StockChartLineChartFactory

+ (id<SChartDatasource>)createChartDatasource {
  // Initialise the data source we will use for the chart
  return [StockChartDataSource new];
}

+ (ShinobiChart*)createChartWithBounds:(CGRect)bounds dataSource:(id<SChartDatasource>)datasource {
  ShinobiChart *chart = [[ShinobiChart alloc] initWithFrame:bounds];
  
  // As the chart is a UIView, set its resizing mask to allow it to automatically resize when screen orientation changes.
  chart.autoresizingMask = ~UIViewAutoresizingNone;
  chart.rotatesOnDeviceRotation = NO;
  
  // Give the chart the data source
  chart.datasource = datasource;
  
  // Set the initial range of the x axis to cover the entirety of the data
  StockChartData *data = [StockChartData getInstance];
  NSDate *startX = data.dates[0];
  NSDate *endX = [data.dates lastObject];
  
  SChartDateRange *dateRange = [[SChartDateRange alloc] initWithDateMinimum:startX
                                                             andDateMaximum:endX];
  // Create a date time axis to use as the x axis.
  SChartDateTimeAxis *xAxis = [[SChartDateTimeAxis alloc] initWithRange:dateRange];
  
  // Disable panning and zooming on the x-axis.
  xAxis.enableGesturePanning = YES;
  xAxis.enableGestureZooming = YES;
  xAxis.enableMomentumPanning =YES;
  xAxis.enableMomentumZooming = YES;
  
  chart.xAxis = xAxis;
  
  // Create a number axis to use as the y axis.
  SChartNumberAxis *yAxis = [SChartNumberAxis new];
  
  // Enable panning and zooming on Y
  yAxis.enableGesturePanning = YES;
  yAxis.enableGestureZooming = YES;
  yAxis.enableMomentumPanning = YES;
  yAxis.enableMomentumZooming = YES;
  
  // Put the yAxis on the RHS
  yAxis.axisPosition = SChartAxisPositionReverse;
  yAxis.width = @50;
  chart.yAxis = yAxis;
  
  return chart;
}

@end
