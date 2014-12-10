//
//  StockChartMomentumAnimation.m
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

#import "StockChartMomentumAnimation.h"
#import <ShinobiCharts/SChartEaseOutAnimationCurve.h>

@interface StockChartMomentumAnimation ()

@property (assign, nonatomic) CGFloat animationStartTime;
@property (assign, nonatomic) CGFloat animationDuration;
@property (copy, nonatomic) void (^positionUpdateBlock)(CGFloat);
@property (assign, nonatomic) CGFloat startPos;
@property (assign, nonatomic) CGFloat endPos;
@property (assign, nonatomic) BOOL animating;
@property (strong, nonatomic) id<SChartAnimationCurve> animationCurve;

@end

@implementation StockChartMomentumAnimation

- (void)animateWithStartPosition:(CGFloat)startPosition startVelocity:(CGFloat)velocity
                     updateBlock:(void (^)(CGFloat))updateBlock {
  [self animateWithStartPosition:startPosition
                   startVelocity:velocity
                        duration:0.3f
                     updateBlock:updateBlock];
}

- (void)animateWithStartPosition:(CGFloat)startPosition startVelocity:(CGFloat)velocity
                        duration:(CGFloat)duration updateBlock:(void (^)(CGFloat))updateBlock {
  [self animateWithStartPosition:startPosition
                   startVelocity:velocity
                        duration:duration
                  animationCurve:[SChartEaseOutAnimationCurve new]
                     updateBlock:updateBlock];
}

- (void)animateWithStartPosition:(CGFloat)startPosition startVelocity:(CGFloat)velocity
                        duration:(CGFloat)duration animationCurve:(id<SChartAnimationCurve>)curve
                     updateBlock:(void (^)(CGFloat))updateBlock {
  
  // Calculate the end position. The positions we are dealing with are proportions
  // and as such are limited to the range [0,1]. The sign of the velocity is used
  // to calculate the direction of the motion, and the magnitude represents how
  // far we should expect to travel
  self.endPos = startPosition + (velocity * duration) / 5;
  
  // Fix to the limits
  // Since position is now relative instead of absolute, the minimum endPos is -1
  // This isn't really necessary because
  // -[ShinobiRangeAnnotationManager ensureWithinChartBounds:maintainingSpan:]
  // also ensures this, but it doesn't hurt.
  if (self.endPos < -1) {
    self.endPos = -1;
  }
  if (self.endPos > 1) {
    self.endPos = 1;
  }
  
  // Save off the required variables as ivars
  self.positionUpdateBlock = updateBlock;
  self.startPos = startPosition;
  
  // Start an animation loop
  self.animationStartTime = CACurrentMediaTime();
  self.animationDuration = duration;
  self.animationCurve = curve;
  self.animating = YES;
  [self continueAnimation];
  
}

- (void)continueAnimation {
  if (CACurrentMediaTime() > self.animationStartTime + self.animationDuration) {
    // We've finished the alloted animation time. Stop animating
    self.animating = NO;
  }
  
  if (self.animating) {
    // Let's update the position
    CGFloat currentTemporalProportion = (CACurrentMediaTime() - self.animationStartTime) / self.animationDuration;
    CGFloat currentSpatialProportion = [self.animationCurve valueAtTime:currentTemporalProportion];
    CGFloat currentPosition = (self.endPos - self.startPos) * currentSpatialProportion + self.startPos;
    
    // Call the block which will perform the repositioning
    self.positionUpdateBlock(currentPosition);
    
    // Recurse. We aim here for 20 updates per second.
    [self performSelector:@selector(continueAnimation) withObject:nil afterDelay:0.05f];
  }
}

- (void)stopAnimation {
  self.animating = NO;
}

@end
