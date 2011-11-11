//
//  NSDate+DateISOParser.h
//  Airpad
//
//  Created by Conrad Irwin on 07/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (DateISOParser)
+ (NSDate *)dateWithISO8601String:(NSString*)string;
@end
