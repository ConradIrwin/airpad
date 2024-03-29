//
//  AirbrakeError.m
//  Airpad
//
//  Created by Conrad Irwin on 11/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeError.h"
#import "AirbrakeProject.h"
#import "NSDate+DateISOParser.h"
#import "NSString+Shortcuts.h"
#import "NSArray+FunctionalUtils.h"


@implementation AirbrakeError

@dynamic airbrakeId;
@dynamic backtrace;
@dynamic earliestSeenAt;
@dynamic isResolved;
@dynamic latestSeenAt;
@dynamic noticesCount;
@dynamic project;
@dynamic user;
@dynamic errorMessage;

@synthesize data;
@synthesize hasDetails, justLoaded;
@synthesize requestedResolve;
@synthesize fetcher;

- (void)importBasicsFromElement: (SMXMLElement *)element {
    
    self.errorMessage   =                                [[element childNamed:@"error-message"] value];
    
    self.noticesCount   = [NSNumber numberWithInteger:  [[[element childNamed:@"notices-count"] value] integerValue]];
    self.isResolved     = [NSNumber numberWithBool:     [[[element childNamed:@"resolved"] value] boolValue]];
    
    self.latestSeenAt   = [NSDate dateWithISO8601String: [[element childNamed:@"most-recent-notice-at"] value]];
    self.earliestSeenAt = [NSDate dateWithISO8601String: [[element childNamed:@"created-at"] value]];
}

- (NSArray *) parseDataFromElement: (SMXMLElement *)element {
    
    
    NSMutableArray *summary     = [[NSMutableArray alloc] init];
    NSMutableArray *params      = [[NSMutableArray alloc] init];
    NSMutableArray *environment = [[NSMutableArray alloc] init];
    
    for (SMXMLElement *child in [[element childNamed: @"request"] childNamed: @"params"].children) {
        if ([child value]) {
            [params addObject: [NSArray arrayWithObjects: [child name], [child value], nil]];
        }
    }
    
    for (SMXMLElement *child in [element childNamed: @"environment"].children) {
        if ([child value]) {
            [environment addObject: [NSArray arrayWithObjects: [child name], [child value], nil]];
        }
    }
    
    [params sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        return [[obj1 objectAtIndex: 0] localizedCaseInsensitiveCompare:[obj2 objectAtIndex:0]];
    }];
    
    [environment sortUsingComparator:^NSComparisonResult(NSArray *obj1, NSArray *obj2) {
        return [[obj1 objectAtIndex: 0] localizedCaseInsensitiveCompare:[obj2 objectAtIndex:0]];
    }];
    
    NSString* url = [[[element childNamed: @"request"] childNamed: @"url"] value];
    if (url && ![url isEqualToString:@""]) {
        [summary addObject: [NSArray arrayWithObjects:@"URL", url, nil]];
    }
    
    NSString* file = [[element childNamed: @"file"] value];
    if (file && ![file isEqualToString:@""]) {
        [summary addObject: [NSArray arrayWithObjects:@"File", file, nil]];
    }
    
    NSString* action = [[element childNamed: @"action"] value];
    NSString* controller = [[element childNamed: @"controller"] value];
    if (action && controller && ![action isEqualToString:@""] && ![controller isEqualToString:@""]) {
        [summary addObject: [NSArray arrayWithObjects:@"Action", [controller stringByAppendingFormat: @"#%@", action], nil]];
    }
    
    
    NSMutableArray *newData     = [[NSMutableArray alloc] init];
    if ([summary count]) {
        [newData addObject: [NSArray arrayWithObjects:@"Summary", summary, nil]];
    }
    if ([params count]) {
        [newData addObject: [NSArray arrayWithObjects:@"Parameters", params, nil]];
    }
    if ([environment count]) {
        [newData addObject: [NSArray arrayWithObjects:@"Environment", environment, nil]];
    }
    
    return newData;
}
- (void)importDetailsFromElement: (SMXMLElement *)element {
    [self willChangeValueForKey:@"details"];
    [self importBasicsFromElement: element];
    
    NSArray *lines = [[[element childNamed:@"backtrace"] childrenNamed:@"line"] mapBlock:^(SMXMLElement *line) {
        return [[[line value]
                     stringByRegex:@".*/gems/" replacement:@""]
                     stringByRegex:@".*\\[PROJECT_ROOT\\]/"replacement:@"app/"];
    }];
    self.backtrace = [lines componentsJoinedByString:@"\n"];

    self.data = [self parseDataFromElement: element];
    
    self.hasDetails = true;
    [self didChangeValueForKey:@"details"];
}

+ (NSSet *)setOfAirbrakesFromXml:(SMXMLDocument *)xml forUser:(AirbrakeUser *)user{
    NSArray *elements = [xml.root childrenNamed:@"group"];    
    NSMutableSet *set = [[NSMutableSet alloc] initWithCapacity: [elements count]];
    
    for (SMXMLElement *element in elements) {
        AirbrakeError *airbrake = [user airbrakeWithId: [[[element childNamed:@"id"] value] integerValue]];
        
        [airbrake importBasicsFromElement: element];
        airbrake.hasDetails = false;
        airbrake.project = [user projectWithId: [[[element childNamed:@"project-id"] value] integerValue]];
        
        [set addObject:airbrake];
    }
    return set;
}

- (double)occurrenceRate {
    NSTimeInterval ti = [self.latestSeenAt timeIntervalSinceDate:self.earliestSeenAt];
    if (floor(ti) < 1) {
        return 0.0;
    } else {
        return [self.noticesCount floatValue] * 86400.0 / ti;
    }
}

- (NSDictionary *)details {
    return [self dictionaryWithValuesForKeys: [NSArray arrayWithObjects: @"airbrakeId", @"errorMessage", @"backtrace", nil]];
}

- (void)loadDetails {
    if (!self.fetcher) {
        self.fetcher = [[PagedXmlFetcher alloc] init];
        self.fetcher.delegate = self;
        [self.fetcher fetchNextPage];
    }
}

- (void) putBody:(NSString*) body {
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[self.user urlForAirbrakeWithId:[self.airbrakeId integerValue]]
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:60.0];
    [request setHTTPMethod: @"PUT"];
    [request setValue: @"application/xml; charset: utf-8" forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody: [body dataUsingEncoding:NSUTF8StringEncoding]];

    
    self.fetcher = [[PagedXmlFetcher alloc] init];
    self.fetcher.delegate = self;
    [self.fetcher fetchPageWithRequest:request];
}

- (void) resolve {
    self.requestedResolve = [NSNumber numberWithBool: true];
    if (![self.isResolved boolValue] && !self.fetcher) {
        [self putBody: @"<group><resolved>true</resolved></group>\n"];
    }
}
- (void) reopen{
    self.requestedResolve = [NSNumber numberWithBool: false];
    if ([self.isResolved boolValue] && !self.fetcher) {
        [self putBody: @"<group><resolved>false</resolved></group>\n"];
    }
}

#pragma mark - pagedXmlFetcher delegate

- (NSURL *)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher urlForPage:(NSInteger)pageNumber {
    return [self.user urlForAirbrakeWithId: [self.airbrakeId integerValue]];
}

- (void)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher didFetchXML:(SMXMLDocument *)document {
    [self importDetailsFromElement: document.root];
    // Don't call fetchNextPage because we don't actually `have` a next page at this point.
    self.fetcher = nil;
    if (self.requestedResolve && [self.requestedResolve boolValue] != [self.isResolved boolValue]) {
        if ([self.requestedResolve boolValue]) {
            [self resolve];
        } else {
            [self reopen];
        }
    }
}

- (void)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher didFailWithError:(NSError *)error {
    [[AirpadAppDelegate sharedDelegate] showDialogForError:error];
}
@end
