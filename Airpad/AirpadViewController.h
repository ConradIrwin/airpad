//
//  AirpadViewController.h
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AirbrakeTablePopulator.h"
#import "AirbrakeError.h"

@interface AirpadViewController : UIViewController<AirbrakePopulatorDelegate>
@property(nonatomic, retain) IBOutlet UITableView *theTable;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *resolveButton;
@property (weak, nonatomic) IBOutlet UITextView *backtraceText;
@property (weak, nonatomic) IBOutlet UILabel *occurrencesLabel;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
- (IBAction)resolveAirbrake:(id)sender;

@property(nonatomic, retain) IBOutlet AirbrakeTablePopulator *populator;
@end