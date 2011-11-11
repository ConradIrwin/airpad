//
//  NSManagedObject+DSL.m
//  Airpad
//
//  Created by Conrad Irwin on 09/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "NSManagedObject+DSL.h"

@implementation NSManagedObject (DSL)

+ (NSFetchRequest *)fetchRequestWithPredicate:(NSString *)predicate, ... {
    NSFetchRequest *fr = [[NSFetchRequest alloc] initWithEntityName: NSStringFromClass(self)];
    va_list args;
    va_start(args, predicate);
    [fr setPredicate: [NSPredicate predicateWithFormat:predicate arguments:args]];
    va_end(args);
    return fr;
}

+ (id) insertNewObjectIntoContext:(NSManagedObjectContext *)context {
    return [NSEntityDescription insertNewObjectForEntityForName: NSStringFromClass(self) 
                                         inManagedObjectContext: context];
}
@end
