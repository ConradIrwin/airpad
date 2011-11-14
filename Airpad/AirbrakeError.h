//
//  AirbrakeError.h
//  Airpad
//
//  Created by Conrad Irwin on 11/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SMXMLDocument.h"
#import "AirbrakeUser.h"
#import "PagedXmlFetcher.h"

@class AirbrakeUser;
@class AirbrakeProject;

@interface AirbrakeError : NSManagedObject <PagedXmlFetcherDelegate>

@property (nonatomic, retain) NSNumber * airbrakeId;
@property (nonatomic, retain) NSString * backtrace;
@property (nonatomic, retain) NSDate * earliestSeenAt;
@property (nonatomic, retain) NSNumber * isResolved;
@property (nonatomic, retain) NSDate * latestSeenAt;
@property (nonatomic, retain) NSNumber * noticesCount;
@property (nonatomic, retain) AirbrakeProject *project;
@property (nonatomic, retain) AirbrakeUser *user;
@property (nonatomic, retain) NSString * errorMessage;

@property (nonatomic, readonly) NSDictionary *details;
@property (nonatomic, retain) NSDictionary *data;

@property (nonatomic) bool hasDetails;
@property (nonatomic) bool justLoaded;
@property (nonatomic, strong) PagedXmlFetcher *fetcher;
@property (nonatomic, strong) NSNumber *requestedResolve;

+ (NSSet *)setOfAirbrakesFromXml:(SMXMLDocument *)xml forUser: (AirbrakeUser *) user;
- (double) occurrenceRate;

- (void) loadDetails;
- (void) resolve;
- (void) reopen;

@end
