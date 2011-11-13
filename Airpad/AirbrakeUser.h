//
//  AirbrakeUser.h
//  Airpad
//
//  Created by Conrad Irwin on 09/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "AirbrakeError.h"
#import "NSManagedObject+DSL.h"
#import "AirbrakeFetcher.h"
#import "ProjectFetcher.h"

@class AirbrakeProject;
@class AirbrakeError;

@interface AirbrakeUser : NSManagedObject

// CoreData
@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * baseUrl;
@property (nonatomic, retain) NSSet *projects;
@property (nonatomic, retain) NSSet *errors;

// Transient worker thingies
@property (nonatomic, strong) AirbrakeFetcher *airbrakeFetcher;
@property (nonatomic, strong) ProjectFetcher *projectFetcher;

// Per-instance things?
@property (nonatomic, copy) NSString *searchFilter;
@property (nonatomic, strong) AirbrakeProject *projectFilter;
@property (nonatomic, strong) AirbrakeError *currentAirbrake;
           
- (void) downloadAirbrakes;

- (AirbrakeProject*)projectWithId:(NSInteger)projectId;
- (NSArray *)sortedProjects;

- (AirbrakeError *)airbrakeWithId:(NSInteger)errorId;
- (NSArray *)sortedAirbrakes;

// ProjectFetcher delegate methods
- (NSURL*)urlForProjectsPage:(NSInteger)pageNumber;
- (void)projectFetcherFinishedFetching;

// AirbrakeFetcher delegate methods
- (NSURL*)urlForAirbrakesPage:(NSInteger)pageNumber;
- (void)airbrakeFetcherFinishedFetching;

// Airbrakes delegate methods
- (NSURL *)urlForAirbrakeWithId:(NSInteger)airbrakeId;

@end

@interface AirbrakeUser (CoreDataGeneratedAccessors)

- (void)addProjectObject:(AirbrakeProject *)value;
- (void)removeProjectObject:(AirbrakeProject *)value;
- (void)addProjects:(NSSet *)values;
- (void)removeProjects:(NSSet *)values;

- (void)addErrorObject:(AirbrakeError *)value;
- (void)removeErrorObject:(AirbrakeError *)value;
- (void)addErrors:(NSSet *)values;
- (void)removeErrors:(NSSet *)values;
@end