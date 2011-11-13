    //
//  UserSettings.h
//  Airpad
//
//  Created by Conrad Irwin on 09/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AirbrakeUser.h"

@interface UserSettings : NSObject
+(UserSettings *) userSettings;
-(NSURL *)urlForErrorsPage:(NSInteger) pageNumber;
-(NSURL *)urlForProjectsPage:(NSInteger) pageNumber;
-(NSURL *)urlForAirbrakeWithId:(NSInteger) airbrakeId;

-(bool)isSetupRequired;
+(AirbrakeUser *)currentUser;
-(AirbrakeUser *)currentUser;
@end
