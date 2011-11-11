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

@protocol ProjectSelectorDelegate
- (void) didSelectProject:(AirbrakeProject *)project;
@end

@interface ProjectsMenuViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (assign, nonatomic) IBOutlet UITableView *theTable;
@property (nonatomic, assign) ProjectFetcher *fetcher;
@property (nonatomic, assign) id<ProjectSelectorDelegate> delegate;
@property (nonatomic, assign) AirbrakeProject* projectFilter;
@end
