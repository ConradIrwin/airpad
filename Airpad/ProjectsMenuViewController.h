//
//  ProjectsMenuViewController.h
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ProjectFetcher.h"
#import "AirbrakeProject.h"
#import "AirbrakeUser.h"

@interface ProjectsMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, weak) IBOutlet UITableView *theTable;
@property (nonatomic, weak) UIPopoverController* popoverController;
@property (nonatomic, strong) AirbrakeUser *user;
@end
