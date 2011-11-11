//
//  NSArray+FunctionalUtils.m
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//
// TODO: hunt for a library of these things online...

#import "NSArray+FunctionalUtils.h"

@implementation NSArray (FunctionAlUtils)
- (NSArray *) mapBlock:(id (^)(id))block {
    NSMutableArray *mapped = [[NSMutableArray alloc] init];
    
    for (id element in self) {
        [mapped addObject: block(element)];
    }
    return mapped;
}
@end

@implementation NSSet (FunctionAlUtils)
- (NSArray *) detectWithBlock:(bool(^)(id))block {   
    for (id element in self) {
        if (block(element)) {
            return element;
        }
    }
    return nil;
}
@end