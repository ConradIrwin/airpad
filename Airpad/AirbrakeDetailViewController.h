//
//  AirbrakeDetailViewController.h
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirbrakePopulatorDelegate.h"
#import "ProjectFetcher.h"
#import "ProjectsMenuViewController.h"
#import "AirbrakeListViewController.h"
#import "DGSwitch.h"
#import "DataTableDelegate.h"

@interface AirbrakeDetailViewController : UIViewController <UISplitViewControllerDelegate, UIPopoverControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *dataTable;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet DGSwitch *resolveSlider;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *occurrenceLabel;
@property (weak, nonatomic) IBOutlet UITextView *backtraceText;
@property (weak, nonatomic) AirbrakeListViewController* listView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *projectMenuButton;

@property (nonatomic, strong) DataTableDelegate *dataTableDelegate;
@property (nonatomic, strong) AirbrakeUser* user;

- (IBAction)projectsClicked:(id)sender;
- (IBAction)openClicked:(id)sender;
- (IBAction)resolveStateChanged:(id)sender;

@end
