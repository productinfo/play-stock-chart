//
//  StockChartRangeAnnotationManager.m
//  StockChart
//
//  Created by Sam Davies on 26/12/2012.
//
//  Copyright 2013 Scott Logic
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

#import "StockChartRangeAnnotationManager.h"
#import <ShinobiCharts/SChartCanvas.h>
#import <ShinobiCharts/SChartGLView.h>
#import "StockChartRangeHandleAnnotation.h"
#import "StockChartRangeSelectionAnnotation.h"
#import "StockChartMomentumAnimation.h"
#import "ShinobiPlayUtils/UIColor+SPUColor.h"

@interface StockChartRangeAnnotationManager ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) ShinobiChart *chart;
@property (strong, nonatomic) SChartAnnotation *leftLine, *leftGripper, *rightGripper, *rightLine;
@property (strong, nonatomic) SChartAnnotationZooming *leftShading, *rightShading, *rangeSelection;
@property (strong, nonatomic) StockChartMomentumAnimation *momentumAnimation;
@property (assign, nonatomic) CGFloat minimumSpan;
@property (assign, nonatomic) CGPoint previousTouchPoint;

@end


@implementation StockChartRangeAnnotationManager

#pragma mark - Constructors
- (instancetype)init {
  NSException *exception = [NSException exceptionWithName:NSInvalidArgumentException
                                                   reason:@"Please use initWithChart:"
                                                 userInfo:nil];
  @throw exception;
}

- (instancetype)initWithChart:(ShinobiChart *)chart {
  return [self initWithChart:chart minimumSpan:3600*24];
}

- (instancetype)initWithChart:(ShinobiChart *)chart minimumSpan:(CGFloat)minSpan {
  self = [super init];
  if (self) {
    self.chart = chart;
    self.minimumSpan = minSpan;
    [self createAnnotations];
    [self prepareGestureRecognisers];
    // Let's make an animation instance here. We'll use this whenever we need momentum
    self.momentumAnimation = [StockChartMomentumAnimation new];
  }
  return self;
}

#pragma mark - Manager setup
- (void)createAnnotations {
  UIColor *color = [UIColor shinobiDarkGrayColor];
  
  // Lines are pretty simple
  self.leftLine = [SChartAnnotation verticalLineAtPosition:nil
                                                 withXAxis:self.chart.xAxis
                                                  andYAxis:self.chart.yAxis
                                                 withWidth:3.f
                                                 withColor:color];
  self.rightLine = [SChartAnnotation verticalLineAtPosition:nil
                                                  withXAxis:self.chart.xAxis
                                                   andYAxis:self.chart.yAxis
                                                  withWidth:3.f
                                                  withColor:color];
  // Shading is either side of the line
  self.leftShading = [SChartAnnotation verticalBandAtPosition:self.chart.xAxis.axisRange.minimum
                                                      andMaxX:nil
                                                    withXAxis:self.chart.xAxis
                                                     andYAxis:self.chart.yAxis
                                                    withColor:[UIColor colorWithWhite:0.1f alpha:0.3f]];
  self.rightShading = [SChartAnnotation verticalBandAtPosition:nil
                                                       andMaxX:self.chart.xAxis.axisRange.maximum
                                                     withXAxis:self.chart.xAxis
                                                      andYAxis:self.chart.yAxis
                                                     withColor:[UIColor colorWithWhite:0.1f alpha:0.3f]];
  // The invisible range selection
  self.rangeSelection = [[StockChartRangeSelectionAnnotation alloc] initWithFrame:CGRectMake(0, 0, 1, 1)
                                                                           xValue:self.chart.xAxis.axisRange.minimum
                                                                        xValueMax:self.chart.xAxis.axisRange.maximum
                                                                            xAxis:self.chart.xAxis
                                                                            yAxis:self.chart.yAxis];
  // Create the handles
  self.leftGripper = [[StockChartRangeHandleAnnotation alloc] initWithFrame:CGRectMake(0, 0, 24, 24)
                                                                      color:color
                                                                     xValue:self.chart.xAxis.axisRange.minimum
                                                                      xAxis:self.chart.xAxis
                                                                      yAxis:self.chart.yAxis];
  self.rightGripper = [[StockChartRangeHandleAnnotation alloc] initWithFrame:CGRectMake(0, 0, 24, 24)
                                                                       color:color
                                                                      xValue:self.chart.xAxis.axisRange.maximum
                                                                       xAxis:self.chart.xAxis
                                                                       yAxis:self.chart.yAxis];
    
  // Add the annotations to the chart
  [self.chart addAnnotation:self.leftLine];
  [self.chart addAnnotation:self.rightLine];
  [self.chart addAnnotation:self.leftShading];
  [self.chart addAnnotation:self.rightShading];
  [self.chart addAnnotation:self.rangeSelection];
  // Add the handles on top so they take gesture priority.
  [self.chart addAnnotation:self.leftGripper];
  [self.chart addAnnotation:self.rightGripper];
}

- (void)prepareGestureRecognisers {
  // We need to stop other subviews of the chart from intercepting touches
  self.chart.userInteractionEnabled = YES;
  for (UIView *v in self.chart.subviews) {
    v.userInteractionEnabled = NO;
  }
  self.chart.canvas.userInteractionEnabled = YES;
  for (UIView *v in self.chart.canvas.subviews) {
    v.userInteractionEnabled = NO;
  }
  self.chart.canvas.glView.userInteractionEnabled = YES;
  
  // Add a pan gesture recogniser for dragging the range selector
  UIPanGestureRecognizer *gestureRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(handlePan:)];
  [self.rangeSelection addGestureRecognizer:gestureRecogniser];
  
  // And pan gesture recognisers for the 2 handles on the range selector
  UIPanGestureRecognizer *leftGripperRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(handleGripperPan:)];
  [self.leftGripper addGestureRecognizer:leftGripperRecogniser];
  UIPanGestureRecognizer *rightGripperRecogniser = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(handleGripperPan:)];
  [self.rightGripper addGestureRecognizer:rightGripperRecogniser];
}

#pragma mark - Gesture events
- (void)handlePan:(UIPanGestureRecognizer*)recogniser {
  // What's the pixel location of the touch?
  CGPoint currentTouchPoint = [recogniser locationInView:self.chart.canvas.glView];
  
  CGPoint difference = CGPointMake(currentTouchPoint.x - self.previousTouchPoint.x,
                                   currentTouchPoint.y - self.previousTouchPoint.y);
  
  self.previousTouchPoint = currentTouchPoint;
  
  if (recogniser.state == UIGestureRecognizerStateBegan) {
    return;
  }
  
  if (recogniser.state == UIGestureRecognizerStateEnded) {
    // Work out some values required for the animation
    // startPosition is normalised so in range [0,1]
    // use as offset, so start at 0
    CGFloat startPosition = 0;
    // startVelocity should be normalised as well
    CGFloat startVelocity = [recogniser velocityInView:self.chart.canvas.glView].x / self.chart.canvas.glView.bounds.size.width;
    
    __block CGFloat prevPosition = 0;
    
    // Use the momentum animator instance we have to start animating the annotation
    [self.momentumAnimation animateWithStartPosition:startPosition startVelocity:startVelocity
                                            duration:1.f updateBlock:^(CGFloat position) {
       // This is the code which will get called to update the position
       CGFloat offset = (position - prevPosition) * self.chart.canvas.bounds.size.width;
       
       prevPosition = position;
       
       // Create the range
       SChartRange *updatedRange = [self rangeShiftedByPixelValue:offset];
       
       // Ensure that this newly created range is within the bounds of the chart
       updatedRange = [self ensureWithinChartBounds:updatedRange maintainingSpan:YES];
       
       // Move the annotation to the correct location
       // We use the internal method so we don't kill the momentum animator
       [self moveRangeSelectorToRange:updatedRange cancelAnimation:NO redraw:YES];
       
       // And fire the delegate method
       [self callRangeDidMoveDelegateWithRange:updatedRange];
     }];
    
  } else {
    // Create the range
    SChartRange *updatedRange = [self rangeShiftedByPixelValue:difference.x];
    
    // Ensure that this newly created range is within the bounds of the chart
    updatedRange = [self ensureWithinChartBounds:updatedRange maintainingSpan:YES];
    
    // Move the annotation to the correct location
    [self moveRangeSelectorToRange:updatedRange];
    
    // And fire the delegate method
    [self callRangeDidMoveDelegateWithRange:updatedRange];
  }
}

- (void)handleGripperPan:(UIPanGestureRecognizer*)recogniser {
  CGPoint currentTouchPoint = [recogniser locationInView:self.chart.canvas.glView];
  
  // What's the new location we've dragged the handle to?
  double newValue = [[self estimateDataValueForPixelValue:currentTouchPoint.x
                                                   onAxis:self.chart.xAxis] doubleValue];
  
  SChartRange *newRange;
  // Update the range with the new value according to which handle we dragged
  if (recogniser.view == self.leftGripper) {
    // Left handle => change the range minimum
    // Check bounds
    if ([self.rightGripper.xValue floatValue] - newValue < self.minimumSpan) {
      newValue = [self.rightGripper.xValue floatValue] - self.minimumSpan;
    }
    newRange = [[SChartRange alloc] initWithMinimum:@(newValue)
                                         andMaximum:self.rightGripper.xValue];
  } else {
    // Right handle => change the range maximum
    // Check bounds
    if (newValue - [self.leftGripper.xValue floatValue] < self.minimumSpan) {
      newValue = [self.leftGripper.xValue floatValue] + self.minimumSpan;
    }
    newRange = [[SChartRange alloc] initWithMinimum:self.leftGripper.xValue
                                         andMaximum:@(newValue)];
  }
  
  // Ensure that this newly created range is within the bounds of the chart
  newRange = [self ensureWithinChartBounds:newRange maintainingSpan:NO];
  
  // Move the selector
  [self moveRangeSelectorToRange:newRange];
  
  // And fire the delegate method
  [self callRangeDidMoveDelegateWithRange:newRange];
}


#pragma mark - Utility Methods
- (void)callRangeDidMoveDelegateWithRange:(SChartRange*)range {
  // We call the delegate a few times, so have wrapped it up in a utility method
  if (self.delegate && [self.delegate respondsToSelector:@selector(rangeAnnotation:didMoveToRange:autoscaleYAxis:)]) {
    [self.delegate rangeAnnotation:self didMoveToRange:range autoscaleYAxis:YES];
  }
}

- (SChartRange*)rangeCentredOnPixelValue:(CGFloat)pixelValue {
  // Find the extent of the current range
  double range = [self.rightLine.xValue doubleValue] - [self.leftLine.xValue doubleValue];
  // Find the new centre location
  double newCentreValue = [[self estimateDataValueForPixelValue:pixelValue onAxis:self.chart.xAxis] doubleValue];
  // Calculate the new limits
  double newMin = newCentreValue - range/2;
  double newMax = newCentreValue + range/2;
  
  // Create the range and return it
  return [[SChartRange alloc] initWithMinimum:@(newMin) andMaximum:@(newMax)];
}

- (SChartRange*)rangeShiftedByPixelValue:(CGFloat)pixelValue {
  // Find the extent of the current range
  double range = [self.rightLine.xValue doubleValue] - [self.leftLine.xValue doubleValue];
  
  SChartAxis *axis = self.chart.xAxis;
  
  // Find the axis range
  SChartRange *rangeObj = axis.axisRange;
  
  // Find the frame of the plot area
  CGRect glFrame = [self.chart getPlotAreaFrame];
  
  // Find the pixel width of the axis
  CGFloat pixelSpan;
  if (axis.axisOrientation == SChartOrientationHorizontal) {
    pixelSpan = glFrame.size.width;
  } else {
    pixelSpan = glFrame.size.height;
  }
  
  // Find the old centre location
  // Assuming that there is a linear map
  // NOTE :: This won't work for discontinuous or logarithmic axes
  double oldCentreValue = range / 2 + [self.leftLine.xValue doubleValue];
  
  // Calculate the offset in value
  double offset = [rangeObj.span doubleValue] / pixelSpan * pixelValue;
  
  // Find the new centre location
  double newCentreValue = oldCentreValue + offset;
  // Calculate the new limits
  double newMin = newCentreValue - range/2;
  double newMax = newCentreValue + range/2;
  
  // Create the range and return it
  return [[SChartRange alloc] initWithMinimum:@(newMin) andMaximum:@(newMax)];
}

- (SChartRange*)ensureWithinChartBounds:(SChartRange*)range maintainingSpan:(BOOL)maintainSpan {
  // If the requested range is bigger than the available, then reset to min/max
  if ([range.span compare:self.chart.xAxis.axisRange.span] == NSOrderedDescending) {
    return [SChartRange rangeWithRange:self.chart.xAxis.axisRange];
  }
  
  if ([range.minimum compare:self.chart.xAxis.axisRange.minimum] == NSOrderedAscending) {
    // Min is below axis range
    if (maintainSpan) {
      CGFloat difference = [self.chart.xAxis.axisRange.minimum doubleValue] - [range.minimum doubleValue];
      return [[SChartRange alloc] initWithMinimum:self.chart.xAxis.axisRange.minimum
                                       andMaximum:@([range.maximum doubleValue] + difference)];
    } else {
      return [[SChartRange alloc] initWithMinimum:self.chart.xAxis.axisRange.minimum
                                       andMaximum:range.maximum];
    }
  }
  
  if ([range.maximum compare:self.chart.xAxis.axisRange.maximum] == NSOrderedDescending) {
    // Max is above axis range
    if (maintainSpan) {
      CGFloat difference = [range.maximum doubleValue] - [self.chart.xAxis.axisRange.maximum doubleValue];
      return [[SChartRange alloc] initWithMinimum:@([range.minimum doubleValue] - difference)
                                       andMaximum:self.chart.xAxis.axisRange.maximum];
    } else {
      return [[SChartRange alloc] initWithMinimum:range.minimum
                                       andMaximum:self.chart.xAxis.axisRange.maximum];
    }
  }
  
  return range;
}

- (id)estimateDataValueForPixelValue:(CGFloat)pixelValue onAxis:(SChartAxis*)axis {
  // What is the axis range?
  SChartRange *range = axis.axisRange;
  
  // What's the frame of the plot area
  CGRect glFrame = [self.chart getPlotAreaFrame];
  
  // Find the pixel width of the axis
  CGFloat pixelSpan;
  if (axis.axisOrientation == SChartOrientationHorizontal) {
    pixelSpan = glFrame.size.width;
  } else {
    pixelSpan = glFrame.size.height;
  }
  
  // Assuming that there is a linear map
  // NOTE :: This won't work for discontinuous or logarithmic axes
  return @( [range.span doubleValue] / pixelSpan * pixelValue + [range.minimum doubleValue] );
}


#pragma mark - API Methods
- (void)moveRangeSelectorToRange:(SChartRange *)range {
  // By default we'll cancel animations and redraw the chart
  [self moveRangeSelectorToRange:range cancelAnimation:YES redraw:NO];
}

- (void)moveRangeSelectorToRange:(SChartRange *)range redraw:(BOOL)redraw {
  // By default we'll cancel animations
  [self moveRangeSelectorToRange:range cancelAnimation:YES redraw:redraw];
}

- (void)setInitialMin:(id)min andMax:(id)max {
  self.leftShading.xValue = min;
  self.rightShading.xValueMax = max;
}

- (void)moveRangeSelectorToRange:(SChartRange *)range cancelAnimation:(BOOL)cancelAnimation
                          redraw:(BOOL)redraw {
  if (cancelAnimation) {
    // In many cases we want to prevent the animation fighting with the UI
    [self.momentumAnimation stopAnimation];
  }
  
  // Update the positions of all the individual components which make up the
  // range annotation
  self.leftLine.xValue = range.minimum;
  self.rightLine.xValue = range.maximum;
  self.leftShading.xValue = self.chart.xAxis.axisRange.minimum;
  self.leftShading.xValueMax = range.minimum;
  self.rightShading.xValue = range.maximum;
  self.rightShading.xValueMax = self.chart.xAxis.axisRange.maximum;
  self.leftGripper.xValue = range.minimum;
  self.rightGripper.xValue = range.maximum;
  self.rangeSelection.xValue = range.minimum;
  self.rangeSelection.xValueMax = range.maximum;
  
  // And finally redraw the chart
  if (redraw) {
    [self.chart redrawChart];
  }
}

@end
