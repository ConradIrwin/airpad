//
//  NSString+Shortcuts.m
//  Airpad
//
//  Created by Conrad Irwin on 11/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "NSString+Shortcuts.h"

@implementation NSString (Shortcuts)
- (bool)containsRegex:(NSString *)string options:(NSInteger)options {
    return [self rangeOfString: string options: (NSRegularExpressionSearch | options)].location != NSNotFound;
}

- (NSString*)stringByRegex:(NSString *)regex replacement:(NSString *)template options:(NSInteger)options {
    NSError *e = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:regex options:0 error:&e];
    NSAssert(!e, @"Got invalid regex: %@", regex);

    return [re stringByReplacingMatchesInString:self
                                        options:0
                                          range:NSMakeRange(0, [self length])
                                   withTemplate:template];
}
- (NSString *)stringByRegex:(NSString *)regex replacement:(NSString *)template {
    return [self stringByRegex:regex replacement:template options:0];
}
@end
