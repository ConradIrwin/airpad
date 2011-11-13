//
//  AirbrakeUser.m
//  Airpad
//
//  Created by Conrad Irwin on 09/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeUser.h"
#import "AirbrakeProject.h"
#import "AirbrakeError.h"
#import "NSArray+FunctionalUtils.h"
#import "NSManagedObject+DSL.h"
#import "ProjectFetcher.h"

@implementation AirbrakeUser;

@dynamic authToken;
@dynamic baseUrl;
@dynamic projects;
@dynamic errors;

@synthesize projectFetcher, airbrakeFetcher;

@synthesize searchFilter, projectFilter, currentAirbrake;

- (AirbrakeProject*) projectWithId:(NSInteger)projectId {
    AirbrakeProject *project = [self.projects detectWithBlock:^bool(AirbrakeProject*ap) {
        return [ap.projectId integerValue] == projectId;
    }];
    
    if (project) {
        return project;
    }
    NSLog(@"Missing projectWithId: %i", projectId);
    project = [AirbrakeProject insertNewObjectIntoContext: [self managedObjectContext]];
    project.projectId = [NSNumber numberWithInteger: projectId];
    project.user = self;
        
    if (!self.projectFetcher) {
        self.projectFetcher = [[ProjectFetcher alloc] initWithUser:self];
    }
    return project;
}

-(NSArray *)sortedProjects {
     NSArray *sortDescriptors = [NSArray arrayWithObject: 
                                 [[NSSortDescriptor alloc] initWithKey:@"name"
                                                             ascending:YES
                                                              selector:@selector(localizedCaseInsensitiveCompare:)
                                  ]];
    return [[self.projects allObjects] sortedArrayUsingDescriptors:sortDescriptors];
}
- (AirbrakeError *) airbrakeWithId:(NSInteger)airbrakeId {
    AirbrakeError *airbrake = [self.errors detectWithBlock:^bool(AirbrakeError*ae) {
        return [ae.airbrakeId integerValue] == airbrakeId;
    }];
    
    if (airbrake) {
        return airbrake;
    }
    airbrake = [AirbrakeError insertNewObjectIntoContext: [self managedObjectContext]];
    airbrake.airbrakeId = [NSNumber numberWithInteger: airbrakeId];
    airbrake.user = self;
    
    [[self mutableSetValueForKey:@"errors"] addObject: airbrake];
    return airbrake;
}
-(NSArray *)sortedAirbrakes {
    NSArray *sortDescriptors = [NSArray arrayWithObject:
                                [[NSSortDescriptor alloc] initWithKey:@"latestSeenAt"
                                                            ascending:NO
                                                            selector:@selector(compare:)]];

    NSFetchRequest *fetch = [AirbrakeError fetchRequestWithPredicate:@"(user = %@)", self];
    [fetch setSortDescriptors:sortDescriptors];
    NSError *e;
    
    NSArray* results = [[self managedObjectContext] executeFetchRequest:fetch error:&e];
    
    if (e) {
        [[AirpadAppDelegate sharedDelegate] showDialogForError:e];
    }
    
    return results;
}

-(void) downloadAirbrakes {
    if (!airbrakeFetcher) {
        airbrakeFetcher = [[AirbrakeFetcher alloc] initWithUser:self];
    }
}

-(void) save
{
    NSError *e;
    [[self managedObjectContext] save: &e];
    if (e) {
        [[AirpadAppDelegate sharedDelegate] showDialogForError:e];
    }
}

#pragma mark - ProjectFetcher delegation.

- (NSURL *)urlForProjectsPage:(NSInteger)pageNumber {
    return [NSURL URLWithString: [NSString stringWithFormat:
                                  @"%@/projects.xml?auth_token=%@&page=%i", [self baseUrl], [self authToken], pageNumber]];
}

- (void)projectFetcherFinishedFetching {
    self.projectFetcher = nil;
    [self save];
}

#pragma mark – AirbrakeFetcher delegation.

- (NSURL *)urlForAirbrakesPage:(NSInteger)pageNumber {
    return [NSURL URLWithString: [NSString stringWithFormat:
                                  @"%@/errors.xml?auth_token=%@&page=%i", [self baseUrl], [self authToken], pageNumber]];
}

- (void)airbrakeFetcherFinishedFetching {
    self.airbrakeFetcher = nil;
    NSMutableSet *toDelete = [[NSMutableSet alloc] init];
    
    for (AirbrakeError *error in self.errors) {
        if (!error.justLoaded && (!currentAirbrake || ![error isEqual: currentAirbrake])) {
            [toDelete addObject:error];
        }
        error.justLoaded = false;
    }
    for (AirbrakeError *error in toDelete) {
        [[self mutableSetValueForKey:@"errors"] removeObject:error];
    }
    NSLog(@"Finished fetching!");
    [self save];
}

#pragma mark – AirbrakeFetcher delegation.

- (NSURL *)urlForAirbrakeWithId:(NSInteger)airbrakeId {
    return [NSURL URLWithString: [NSString stringWithFormat:
                                  @"%@/errors/%i.xml?auth_token=%@", [self baseUrl], airbrakeId, [self authToken]]];
}

@end
