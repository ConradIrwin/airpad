//
//  NSArray+FunctionalUtils.h
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FunctionalUtils)
-(NSArray *)mapBlock: (id(^)(id)) block;
@end


@interface NSSet (FunctionalUtils)
-(id)detectWithBlock: (bool(^)(id)) block;
@end