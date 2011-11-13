//
//  AirbrakeFetcher.m
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeFetcher.h"
#import "AirbrakeError.h"
#import "PagedXmlFetcher.h"
#import "NSArray+FunctionalUtils.h"
#import "UserSettings.h"
#import "AirpadAppDelegate.h"

@implementation AirbrakeFetcher
@synthesize user;
@synthesize fetcher;

- (AirbrakeFetcher *)initWithUser:(AirbrakeUser *)_user{
    self = [self init];
    if (self) {
        self.user = _user;
        self.fetcher = [[PagedXmlFetcher alloc] init];
        self.fetcher.delegate = self;
       [self.fetcher fetchNextPage];
    }
    return self;
}

- (NSURL *)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher urlForPage:(NSInteger)pageNumber {
    return [[UserSettings userSettings] urlForErrorsPage:pageNumber];
}

- (void)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher didFetchXML:(SMXMLDocument *)document
{
    NSArray* newElements = [[document root] childrenNamed: @"group"];
    
    if ([newElements count]) {
        NSSet *airbrakes = [AirbrakeError setOfAirbrakesFromXml:document forUser:self.user];
        
        // FIXME: sync is hard :(.
        for (AirbrakeError *airbrake in airbrakes) {
            airbrake.justLoaded = true; 
        }
        [self.fetcher fetchNextPage];
    } else {
        self.fetcher = nil;
        [user airbrakeFetcherFinishedFetching];
    }
}

- (void)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher didFailWithError:(NSError *)error {
    [[AirpadAppDelegate sharedDelegate] showDialogForError:error];
}

@end
