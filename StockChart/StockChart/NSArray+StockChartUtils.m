//
//  NSArray+BinarySearch.m
//  RangeSelector
//
//  Created by Sam Davies on 10/01/2013.
//  Copyright (c) 2013 Shinobi Controls. All rights reserved.
//

#import "NSArray+StockChartUtils.h"

@implementation NSArray (StockChartUtils)

- (NSUInteger)indexOfSmallestObjectBiggerThan:(id)searchKey inSortedRange:(NSRange)range {
  if (range.length == 0) {
    return range.location;
  }
  // Check the boundary condition
  if ([searchKey compare:self[NSMaxRange(range)-1]] == NSOrderedDescending) {
    NSException *exception = [NSException exceptionWithName:NSRangeException
                                                     reason:@"All array elements in range are smaller than the search object"
                                                   userInfo:nil];
    @throw exception;
  }
  
  return [self indexOfClosestObjectToSearchKey:searchKey
                                       inRange:range
                                  withOrdering:NSOrderedAscending];
}


- (NSUInteger)indexOfBiggestObjectSmallerThan:(id)searchKey inSortedRange:(NSRange)range {
  if ([searchKey compare:self[range.location]] == NSOrderedAscending) {
    NSException *exception = [NSException exceptionWithName:NSRangeException
                                                     reason:@"All array elements in range are bigger than the search object."
                                                   userInfo:nil];
    @throw exception;
  }
  return [self indexOfClosestObjectToSearchKey:searchKey
                                       inRange:range
                                  withOrdering:NSOrderedDescending];
}

- (NSUInteger)indexOfClosestObjectToSearchKey:(id)searchKey inRange:(NSRange)range
                                 withOrdering:(NSComparisonResult)ordering {
  
  if (range.length == 0) {
    // We have got it down to one result. Now to work out which index we
    // should return.
    // Descending => biggest one which is smaller
    // Ascending  => Smallest one which is bigger
    return ordering == NSOrderedAscending ? range.location : range.location - 1;
  }
  
  // We need to continue searching. Find the midpoint
  NSInteger mid = range.location + range.length / 2;
  id midVal = self[mid];
  
  switch ([midVal compare:searchKey]) {
    case NSOrderedDescending:
      // This means the value we want is in the first half
      return [self indexOfClosestObjectToSearchKey:searchKey
                                           inRange:NSMakeRange(range.location, mid - range.location)
                                      withOrdering:ordering];
    case NSOrderedAscending:
      // This means the value we want must be in the 2nd half
      return [self indexOfClosestObjectToSearchKey:searchKey
                                           inRange:NSMakeRange(mid + 1, NSMaxRange(range) - (mid+1))
                                      withOrdering:ordering];
    default:
      return mid;
  }
}

- (NSComparisonResult)compareObject1:(id)object1 toObject2:(id)object2 {
  // We are happy to compare object in the following cases:
  // 1) Both objects are of the same type
  // 2) Both objects inherit from NSNumber. This case is required because of some of the subclasses
  // of NSNumber which appear when using CoreData.
  if (([object1 class] != [object2 class]) && !([object1 isKindOfClass:[NSNumber class]] && [object2 isKindOfClass:[NSNumber class]])) {
    NSException* exception = [NSException
                              exceptionWithName:@"IllegalArgumentException"
                              reason:[NSString stringWithFormat:@"Objects must be of the same type"]
                              userInfo:nil];
    @throw exception;
  }
  if ([[object1 class] instancesRespondToSelector:@selector(compare:)])   {
    return [object1 compare:object2];
  } else {
    NSException* exception = [NSException
                              exceptionWithName:@"IllegalArgumentException"
                              reason:[NSString stringWithFormat:@"Can only currently compare objects which have a compare: method"]
                              userInfo:nil];
    @throw exception;
  }
}

- (id)minInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx {
  return [self findExtremeObjectInRangeFromIndex:startIdx toIndex:endIdx withComparison:NSOrderedAscending];
}

- (id)maxInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx {
  return [self findExtremeObjectInRangeFromIndex:startIdx toIndex:endIdx withComparison:NSOrderedDescending];
}

- (id)findExtremeObjectInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx withComparison:(NSComparisonResult)comp {
  if (endIdx >= self.count) {
    endIdx = self.count - 1;
  }
  
  if (startIdx > endIdx) {
    startIdx = endIdx;
  }
  
  if (startIdx == endIdx) {
    return self[startIdx];
  }
  
  id extremeValue = self[startIdx];
  
  for(NSUInteger i = startIdx + 1; i <= endIdx; i++) {
    id value = self[i];
    if ([self compareObject1:value toObject2:extremeValue] == comp) {
      extremeValue = value;
    }
  }
  return extremeValue;
}

@end
