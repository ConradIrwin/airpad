//
//  AirbrakeProject.h
//  Airpad
//
//  Created by Conrad Irwin on 10/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AirbrakeError2, AirbrakeUser;

@interface AirbrakeProject : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * projectId;
@property (nonatomic, retain) NSSet *errors;
@property (nonatomic, retain) AirbrakeUser *user;
@end

@interface AirbrakeProject (CoreDataGeneratedAccessors)

- (void)addErrorsObject:(AirbrakeError2 *)value;
- (void)removeErrorsObject:(AirbrakeError2 *)value;
- (void)addErrors:(NSSet *)values;
- (void)removeErrors:(NSSet *)values;

@end
