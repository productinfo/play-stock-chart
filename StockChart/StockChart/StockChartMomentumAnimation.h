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

#import <Foundation/Foundation.h>
#import <ShinobiCharts/SChartAnimationCurve.h>


/**
 MomentumAnimation is a general purpose 1-dimensional utility class which will
 allows animation of any object.
 */
@interface StockChartMomentumAnimation : NSObject

/**
 Default duration of 0.3s and animation curve of SChartAnimationCurveEaseOut
 */
- (void)animateWithStartPosition:(CGFloat)startPosition startVelocity:(CGFloat)velocity
                     updateBlock:(void (^)(CGFloat position))updateBlock;

/**
 Default animation curve of SChartAnimationCurveEaseOut
 */
- (void)animateWithStartPosition:(CGFloat)startPosition startVelocity:(CGFloat)velocity
                        duration:(CGFloat)duration updateBlock:(void (^)(CGFloat))updateBlock;

/**
 Creates an animation which begins at a given (normalised) position with a (normalised)
 velocity.
 @param startPosition  The start position of the object. In range [0,1]
 @param startVelocity  The start velocity of the object. Normalised
 @param duration       The duration of the animation (in seconds)
 @param animationCurve The shape of the curve used for animation.
 @param updateBlock    This block will be repeatedly called with new position values
                       These values will be normalised (i.e. in the same space as startPosition)
 */
- (void)animateWithStartPosition:(CGFloat)startPosition startVelocity:(CGFloat)velocity
                        duration:(CGFloat)duration animationCurve:(id<SChartAnimationCurve>)curve
                     updateBlock:(void (^)(CGFloat))updateBlock;

/**
 Cancels any animations which are currently in progress
 */
- (void)stopAnimation;

@end
