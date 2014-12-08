//
//  NSArray+BinarySearch.h
//  RangeSelector
//
//  Created by Sam Davies on 10/01/2013.
//  Copyright (c) 2013 Shinobi Controls. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (StockChartUtils)

- (NSUInteger)indexOfSmallestObjectBiggerThan:(id)searchKey inSortedRange:(NSRange)range;
- (NSUInteger)indexOfBiggestObjectSmallerThan:(id)searchKey inSortedRange:(NSRange)range;

- (id)minInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx;
- (id)maxInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx;


@end
