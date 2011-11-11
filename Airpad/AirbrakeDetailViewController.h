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

@interface AirbrakeDetailViewController : UIViewController <UISplitViewControllerDelegate, AirbrakePopulatorDelegate, UIPopoverControllerDelegate, ProjectSelectorDelegate>
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIButton *resolveButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *occurrenceLabel;
@property (weak, nonatomic) IBOutlet UITextView *backtraceText;
@property (weak, nonatomic) AirbrakeListViewController* listView;
@property (retain, nonatomic) ProjectFetcher* projectFetcher;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *projectMenuButton;
- (IBAction)resolveClicked:(id)sender;
- (IBAction)projectsClicked:(id)sender;
- (IBAction)openClicked:(id)sender;

@end
