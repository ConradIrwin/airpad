//
//  AirbrakeUser.m
//  Airpad
//
//  Created by Conrad Irwin on 09/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeUser.h"
#import "AirbrakeProject.h"
#import "NSArray+FunctionalUtils.h"
#import "NSManagedObject+DSL.h"
#import "ProjectFetcher.h"

@implementation AirbrakeUser{
    ProjectFetcher *projectFetcher;
}

@dynamic authToken;
@dynamic baseUrl;
@dynamic projects;

- (AirbrakeProject*) projectWithId:(NSInteger)projectId {
    AirbrakeProject *project = [self.projects detectWithBlock:^bool(AirbrakeProject*ap) {
        return [ap.projectId integerValue] == projectId;
    }];
    
    if (project) {
        return project;
    }
    
    project = [AirbrakeProject insertNewObjectIntoContext: [self managedObjectContext]];
    project.projectId = [NSNumber numberWithInteger: projectId];
    [[self mutableSetValueForKey:@"projects"] addObject:project];
    
    if (!projectFetcher) {
        projectFetcher = [[ProjectFetcher alloc] initWithUser:self];
    }
    return project;
}

- (NSURL *)urlForProjectsPage:(NSInteger)pageNumber {
    return [NSURL URLWithString: [NSString stringWithFormat:
                                  @"%@/projects.xml?auth_token=%@&page=%i", [self baseUrl], [self authToken], pageNumber]];
}

- (void)projectFetcherFinishedFetching {
    projectFetcher = nil;
}

@end
