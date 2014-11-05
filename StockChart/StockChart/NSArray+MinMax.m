//
//  NSArray+MinMax.m
//  ShinobiControls
//
//  Created by Sam Davies on 01/06/2012.
//  Copyright (c) 2012 Scott Logic. All rights reserved.
//

#import "NSArray+MinMax.h"

@implementation NSArray (MinMax)

- (id)minInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx
{
    return [self findExtremeObjectInRangeFromIndex:startIdx toIndex:endIdx withComparison:NSOrderedAscending];
}

- (id)maxInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx
{
    return [self findExtremeObjectInRangeFromIndex:startIdx toIndex:endIdx withComparison:NSOrderedDescending];
}

- (id)findExtremeObjectInRangeFromIndex:(NSUInteger)startIdx toIndex:(NSUInteger)endIdx withComparison:(NSComparisonResult)comp
{
    if(endIdx >= self.count) {
        /* Not going to fail angrily
        NSException *exception = [NSException exceptionWithName:@"IllegalArgumentException"
                                                         reason:@"End index must be within array length" userInfo:nil];
        @throw exception;
         */
        endIdx = self.count - 1;
    }
    
    if(startIdx > endIdx) {
        /* Not going to fail angrily
        NSException *exception = [NSException exceptionWithName:@"IllegalArgumentException"
                                                         reason:@"Start index must be < end index" userInfo:nil];
        @throw exception;
         */
        startIdx = endIdx;
    }
    
    if(startIdx == endIdx) {
        return [self objectAtIndex:startIdx];
    }
    
    id extremeValue = [self objectAtIndex:startIdx];
    
    for(int i = startIdx + 1; i <= endIdx; i++) {
        id value = [self objectAtIndex:i];
        if ([self compareObject1:value ToObject2:extremeValue] == comp) {
            extremeValue = value;
        }
    }
    return extremeValue;
}

- (NSComparisonResult)compareObject1: (id)object1 ToObject2: (id)object2   {
    if ([object1 class] != [object2 class]) {
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
@end
