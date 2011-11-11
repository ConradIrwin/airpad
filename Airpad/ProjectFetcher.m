//
//  ProjectFetcher.m
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "ProjectFetcher.h"
#import "PagedXmlFetcher.h"
#import "NSArray+FunctionalUtils.h"
#import "UserSettings.h"
#import "AirpadAppDelegate.h"

@implementation ProjectFetcher {
    NSMutableArray *projects;
    PagedXmlFetcher *fetcher;
    AirbrakeUser *user;
}
@synthesize projects;

-(ProjectFetcher *)initWithUser:(AirbrakeUser *)_user {
    self = [self init];
    user = _user;
    self->fetcher = [[PagedXmlFetcher alloc] init];
    self->fetcher.delegate = self;
    [self->fetcher fetchNextPage];
    return self;
}

- (NSURL *)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher urlForPage:(NSInteger)pageNumber {
    return [user urlForProjectsPage:pageNumber];
}

- (void)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher didFetchXML:(SMXMLDocument *)document {
    NSArray *array = [document.root childrenNamed:@"project"];
    for (SMXMLElement* e in array) {
        NSInteger projectId = [[[e childNamed:@"id"] value] integerValue];
        NSString* name = [[e childNamed:@"name"] value];

        [[user projectWithId:projectId] setName: name];
    };
    
    if ([array count]) {
        [fetcher fetchNextPage];
    } else {
        fetcher = nil;
        [user projectFetcherFinishedFetching];
    }
}

- (void)pagedXmlFetcher:(PagedXmlFetcher *)pagedXmlFetcher didFailWithError:(NSError *)error {
    [[AirpadAppDelegate sharedDelegate] showDialogForError:error];
}

@end
