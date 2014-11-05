//
//  ArrowHeadView.h
//  ShinobiControls
//
//  Created by  on 21/05/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StockChartArrowHead : UIView

@property (nonatomic, strong) UIColor *color;
@property (nonatomic, assign) float arrowHeadPointYValue;

- (id)initWithFrame:(CGRect)frame color:(UIColor*)color;

@end
