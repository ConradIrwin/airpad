//
//  UserSettings.m
//  Airpad
//
//  Created by Conrad Irwin on 09/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "UserSettings.h"
#import "AirbrakeUser.h"
#import "AirpadAppDelegate.h"
#import "NSManagedObject+DSL.h"

@implementation UserSettings {
    AirbrakeUser *_user;
}

+ (AirbrakeUser *) currentUser {
    return [[self userSettings] currentUser];
}

+ (UserSettings *)userSettings {
    static UserSettings *userSettings;
    if (!userSettings) {
        userSettings = [[UserSettings alloc] init];

    }
    return userSettings;
}

-(NSString *)storedBaseUrl {
    NSString *stored = [[NSUserDefaults standardUserDefaults] stringForKey:@"baseUrl"];
    if (stored) {
        return stored;
    } else {
        return @"";
    }
}

-(NSString *)storedAuthToken {
    NSString *stored = [[NSUserDefaults standardUserDefaults] stringForKey:@"authToken"];
    if (stored) {
        return stored;
    } else {
        return @"";
    }
}

-(NSString *)baseUrl {
    return @"https://rapportive.airbrake.io";
}
-(NSString *)authToken {
    return @"b8b8d6d1f019181009dfa29a299f62255c64eb93";
}

-(bool)isSetupRequired {
    return !([[self baseUrl] length] && [[self authToken] length]);
}

// FIXME: Url-escaping!
- (NSURL *)urlForErrorsPage:(NSInteger)pageNumber {
    return [NSURL URLWithString: [NSString stringWithFormat:
             @"%@/errors.xml?auth_token=%@&page=%i", [self baseUrl], [self authToken], pageNumber]];
}

- (NSURL *)urlForProjectsPage:(NSInteger)pageNumber {
    return [NSURL URLWithString: [NSString stringWithFormat:
                                  @"%@/projects.xml?auth_token=%@&page=%i", [self baseUrl], [self authToken], pageNumber]];
}

- (NSURL *)urlForAirbrakeWithId:(NSInteger)airbrakeId {
    return [NSURL URLWithString: [NSString stringWithFormat:
                                  @"%@/errors/%i.xml?auth_token=%@", [self baseUrl], airbrakeId, [self authToken]]];
}

- (AirbrakeUser *) currentUser{
    
    if (_user) {
        return _user;
    }
    
    NSManagedObjectContext *context = [AirpadAppDelegate sharedDelegate].managedObjectContext;
    NSFetchRequest *fetchRequest = [AirbrakeUser fetchRequestWithPredicate: @"(authToken = %@ AND baseUrl = %@)",
                                                                            [self authToken], [self baseUrl]];
    NSError *e;
    NSArray *users = [context executeFetchRequest:fetchRequest error:&e];
    
    if (e) {
        [[AirpadAppDelegate sharedDelegate] showDialogForError:e];
    }
    
    if ([users count]) {
        _user = [users objectAtIndex:0];
        return _user;
    }

    _user = [AirbrakeUser insertNewObjectIntoContext: context]; 
    [_user setBaseUrl: [self baseUrl]];
    [_user setAuthToken: [self authToken]];
    [context save: &e];
    
    if (e) {
        [[AirpadAppDelegate sharedDelegate] showDialogForError:e];
    }
    
    return _user;
}


@end
