//
//  AirpadAppDelegate.h
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirbrakeFetcher.h"
#import "IASKAppSettingsViewController.h"

@class AirpadViewController;

@interface AirpadAppDelegate : UIResponder <UIApplicationDelegate, IASKSettingsDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UISplitViewController *viewController;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;
- (void)showDialogForError:(NSError*)error;
+ (AirpadAppDelegate *) sharedDelegate;
@end