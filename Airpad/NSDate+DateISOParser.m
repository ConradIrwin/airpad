//
//  NSDate+DateISOParser.m
//  Airpad
//
//  Created by Conrad Irwin on 07/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "NSDate+DateISOParser.h"

@implementation NSDate (DateISOParser)

+ dateWithISO8601String:(NSString*)string {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];   
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss'Z'"];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [dateFormatter dateFromString:string];
}

@end