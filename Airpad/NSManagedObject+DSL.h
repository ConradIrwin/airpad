//
//  NSManagedObject+DSL.h
//  Airpad
//
//  Created by Conrad Irwin on 09/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (DSL)
+ (NSFetchRequest *) fetchRequestWithPredicate:(NSString *) predicate, ...;
+ (id) insertNewObjectIntoContext: (NSManagedObjectContext *) context;
@end
