//
//  AirbrakeUser.h
//  Airpad
//
//  Created by Conrad Irwin on 09/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AirbrakeProject;

@interface AirbrakeUser : NSManagedObject

@property (nonatomic, retain) NSString * authToken;
@property (nonatomic, retain) NSString * baseUrl;
@property (nonatomic, retain) NSSet *projects;
@end

@interface AirbrakeUser (CoreDataGeneratedAccessors)

- (void)addProjectObject:(AirbrakeProject *)value;
- (void)removeProjectObject:(AirbrakeProject *)value;
- (void)addProjects:(NSSet *)values;
- (void)removeProjects:(NSSet *)values;

- (AirbrakeProject*)projectWithId:(NSInteger)projectId;
- (NSURL*)urlForProjectsPage:(NSInteger)pageNumber;
-(void)projectFetcherFinishedFetching;
@end