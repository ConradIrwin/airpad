//
//  AirbrakeListViewController.h
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirbrakePopulatorDelegate.h"
#import "AirbrakeFetcher.h"
#import "AirbrakeProject.h"

@interface AirbrakeListViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBox;
@property (weak, nonatomic) IBOutlet UITableView *airbrakeTable;
@property(nonatomic, assign) id<AirbrakePopulatorDelegate> delegate;
@property(nonatomic, retain) AirbrakeFetcher* fetcher;
@property(nonatomic, retain) AirbrakeProject* projectFilter; 
@end
