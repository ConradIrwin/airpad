//
//  NSString+Shortcuts.h
//  Airpad
//
//  Created by Conrad Irwin on 11/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Shortcuts)
- (bool) containsRegex:(NSString*)string options:(NSInteger)options;
- (NSString*) stringByRegex:(NSString*)regex replacement:(NSString*)template;
- (NSString*) stringByRegex:(NSString*)regex replacement:(NSString*)template options:(NSInteger)options;
@end
