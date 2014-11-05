//
//  NSArray+MinMax.h
//  ShinobiControls
//
//  Created by Sam Davies on 01/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (MinMax)

- (id)minInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx;
- (id)maxInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx;

@end
