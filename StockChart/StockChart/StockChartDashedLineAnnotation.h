//
//  DashedLineAnnotation.h
//  ShinobiControls
//
//  Created by Sam Davies on 29/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ShinobiCharts/ShinobiCharts.h>

@interface StockChartDashedLineAnnotation : SChartAnnotation

@property (nonatomic, strong) UIBezierPath *dashedLine;

- (id)initWithYValue:(id)yValue xAxis:(SChartAxis *)xAxis yAxis:(SChartAxis*)yAxis;

@end
