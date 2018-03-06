//
//  StockChartCrosshairTooltip.m
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

#import "StockChartCrosshairTooltip.h"
#import <ShinobiCharts/SChartCanvas.h>
#import "ShinobiPlayUtils/UIColor+SPUColor.h"
#import "ShinobiPlayUtils/UIFont+SPUFont.h"
#import "StockChartDataSource.h"

static const CGFloat StockChartTooltipLabelPadding = 7.f;
static const CGFloat StockChartTooltipTopPadding = 50.f;

@interface StockChartCrosshairTooltip ()

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSNumberFormatter *volumeFormatter;

@property (strong, nonatomic) UILabel *topLabel;
@property (strong, nonatomic) UILabel *openLabel;
@property (strong, nonatomic) UILabel *highLabel;
@property (strong, nonatomic) UILabel *lowLabel;
@property (strong, nonatomic) UILabel *closeLabel;
@property (strong, nonatomic) UILabel *volumeLabel;

@property (strong, nonatomic) NSArray *allLabels;

@end

@implementation StockChartCrosshairTooltip

- (instancetype)init {
  self = [super init];
  if (self) {
    self.dateFormatter = [NSDateFormatter new];
    [self.dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    [self.dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    
    self.volumeFormatter = [NSNumberFormatter new];
    [self.volumeFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    self.volumeFormatter.maximumFractionDigits = 0;
    
    self.topLabel = [self createTooltipLabel];
    self.topLabel.font = [UIFont boldShinobiFontOfSize:14];
    [self addSubview:self.topLabel];
    
    self.openLabel = [self createTooltipLabel];
    [self addSubview:self.openLabel];
    
    self.highLabel = [self createTooltipLabel];
    [self addSubview:self.highLabel];
    
    self.lowLabel = [self createTooltipLabel];
    [self addSubview:self.lowLabel];
    
    self.closeLabel = [self createTooltipLabel];
    [self addSubview:self.closeLabel];
    
    self.volumeLabel = [self createTooltipLabel];
    [self addSubview:self.volumeLabel];
    
    self.allLabels = @[self.topLabel, self.openLabel, self.highLabel, self.lowLabel,
                       self.closeLabel, self.volumeLabel];
    
    self.layer.borderColor = [UIColor shinobiDarkGrayColor].CGColor;
    self.layer.borderWidth = 1;
    self.layer.cornerRadius = 3;
    self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.8];
  }
  return self;
}

// Method to create a label to add to the tooltip
- (UILabel*)createTooltipLabel {
  UILabel *newLabel = [[UILabel alloc] initWithFrame:CGRectZero];
  newLabel.backgroundColor = [UIColor clearColor];
  newLabel.font = [UIFont shinobiFontOfSize:13];
  newLabel.textColor = [UIColor shinobiDarkGrayColor];
  return newLabel;
}

- (void)setXPosition:(CGFloat)xPosition andData:(NSDictionary *)dataValues inChart:(ShinobiChart *)chart {
  // Date
  NSString *formattedDateString = [self.dateFormatter stringFromDate:dataValues[@"Date"]];
  self.topLabel.text = [NSString stringWithFormat:@"%@", formattedDateString];
  self.topLabel.textAlignment = NSTextAlignmentLeft;
  
  // OHLC data
  self.openLabel.text = [NSString stringWithFormat:@"Open: %.2f", [dataValues[@"Open"] floatValue]];
  self.highLabel.text = [NSString stringWithFormat:@"High: %.2f", [dataValues[@"High"] floatValue]];
  self.lowLabel.text = [NSString stringWithFormat:@"Low: %.2f", [dataValues[@"Low"] floatValue]];
  self.closeLabel.text = [NSString stringWithFormat:@"Close: %.2f", [dataValues[@"Close"] floatValue]];

  // Volume data (line series with standard data points)
  self.volumeLabel.text = [NSString stringWithFormat:@"Volume: %@",
                           [self.volumeFormatter stringFromNumber:dataValues[@"Volume"]]];
  
  // Lay out the labels, keeping track of the maximum width
  CGFloat maxLabelWidth = 0;
  CGFloat labelYPosition = StockChartTooltipLabelPadding;
  
  for (UILabel *label in self.allLabels) {
    // Position the label
    [label sizeToFit];
    CGRect frame = label.frame;
    frame.origin.x = StockChartTooltipLabelPadding;
    frame.origin.y = labelYPosition;
    label.frame = frame;
    
    maxLabelWidth = MAX(maxLabelWidth, label.frame.size.width);
    labelYPosition += label.frame.size.height;
  }
  
  CGRect newFrame = self.frame;
  CGRect plotArea = chart.plotAreaFrame;
  newFrame.size.width = maxLabelWidth + (2 * StockChartTooltipLabelPadding);
  newFrame.size.height = labelYPosition + StockChartTooltipLabelPadding;
  newFrame.origin.y = plotArea.origin.y + StockChartTooltipTopPadding;
  if (xPosition + newFrame.size.width > plotArea.size.width) {
    newFrame.origin.x = plotArea.size.width - newFrame.size.width;
  } else if (xPosition < 0) {
    newFrame.origin.x = 0;
  } else {
    newFrame.origin.x = xPosition;
  }
  
  self.frame = newFrame;
}
@end
