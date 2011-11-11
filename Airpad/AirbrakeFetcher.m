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

@implementation AirbrakeFetcher {
    NSMutableArray *_airbrakes;
    
    NSMutableString *currentString;
    AirbrakeError *currentAirbrake;
    PagedXmlFetcher *fetcher;
}
@synthesize airbrakes=_airbrakes;

- (AirbrakeFetcher *)init{
    self = [super init];
    self->_airbrakes = [[NSMutableArray alloc] init];
    self->fetcher = [[PagedXmlFetcher alloc] init];
    self->fetcher.delegate = self;
    [self->fetcher fetchNextPage];
    return self;
}

- (NSURL *)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher urlForPage:(NSInteger)pageNumber {
    return [[UserSettings userSettings] urlForErrorsPage:pageNumber];
}

- (NSArray *) convertToAirbrakes:(NSArray *)elements {    
    return [elements mapBlock: ^(SMXMLElement* e) {
        AirbrakeError *airbrake = [[AirbrakeError alloc] initWithBasics:e];
        return airbrake;
    }];
}

- (void)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher didFetchXML:(SMXMLDocument *)document {
    NSArray* newElements = [[document root] childrenNamed: @"group"];
    
    if ([newElements count]) {
        [[self mutableArrayValueForKey: @"airbrakes"] addObjectsFromArray:[self convertToAirbrakes: newElements]];
     //   [fetcher fetchNextPage];
    } else {
        fetcher = nil;
    }
}

- (void)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher didFailWithError:(NSError *)error {
    [[AirpadAppDelegate sharedDelegate] showDialogForError:error];
}

@end
