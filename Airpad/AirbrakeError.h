//
//  AirbrakeError.h
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMXMLDocument.h"
#import "NSDate+DateISOParser.h"
#import <CoreData/CoreData.h>

@interface AirbrakeError : NSObject <NSURLConnectionDelegate>

@property(nonatomic, retain) SMXMLElement *basics;
@property(nonatomic, retain) SMXMLElement *details;
-(AirbrakeError *)initWithBasics:(SMXMLElement *)basics;
-(void)fetchDetails;
-(NSString*)title;
-(NSInteger)airbrakeId;
-(NSString*)backtrace;
-(NSInteger)occurrenceCount;
-(NSInteger)projectId;
-(double)occurrenceRate;
-(bool)isResolved;
-(void)resolve;
-(void)reopen;
-(NSDate *)earliestSeenAt;
-(NSDate *)latestSeenAt;
@end
