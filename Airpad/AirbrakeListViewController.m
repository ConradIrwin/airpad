//
//  AirbrakeListViewController.m
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeListViewController.h"
#import "AirbrakeFetcher.h"
#import "AirbrakeError.h"
#import "UserSettings.h"
#import "NSString+Shortcuts.h"
#import "AirbrakeErrorCell.h"

@implementation AirbrakeListViewController

@synthesize searchBox;
@synthesize airbrakeTable;
@synthesize user;
@synthesize visibleAirbrakes;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    return self;
}

- (void) cleanup
{
    if (self.user) {
        [self.user removeObserver:self forKeyPath:@"errors"       ];
        [self.user removeObserver:self forKeyPath:@"searchFilter" ];
        [self.user removeObserver:self forKeyPath:@"projectFilter"];
    }
    self.visibleAirbrakes = nil;
}

- (void) dealloc
{
    [self cleanup];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    user = [UserSettings currentUser];
    [user addObserver:self forKeyPath:@"errors"        options:0 context:@"refresh"];
    [user addObserver:self forKeyPath:@"searchFilter"  options:0 context:@"refresh"];
    [user addObserver:self forKeyPath:@"projectFilter" options:0 context:@"refresh"];
    [self recalculateVisible];
    [self.airbrakeTable reloadData];
}
- (void)viewDidUnload
{
    [self cleanup];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void) recalculateVisible
{
    NSMutableArray *res = [NSMutableArray arrayWithObjects: nil];
    for (AirbrakeError *ab in user.sortedAirbrakes) {
        bool shouldAdd = true;
        
        if (shouldAdd && user.projectFilter) {
            shouldAdd = user.projectFilter == ab.project;
        }
        
        if (shouldAdd && user.searchFilter && ![user.searchFilter isEqualToString:@""]) {
            shouldAdd = [ab.errorMessage containsRegex: user.searchFilter options: NSCaseInsensitiveSearch];
        }
        
        if (shouldAdd) {
            [res addObject: ab];
        }
    }
    self.visibleAirbrakes = res;  
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"refresh") {
        [self recalculateVisible];
        [airbrakeTable reloadData];
        if (user.currentAirbrake) {
            NSInteger index = [visibleAirbrakes indexOfObject:user.currentAirbrake];
            if (index != NSNotFound) {
                [airbrakeTable selectRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
            }
        }
    } else {
        NSLog(@"Received unexpected event!");  
    }
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [visibleAirbrakes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AirbrakeErrorCell* cell = [[AirbrakeErrorCell alloc] init];
    cell.airbrake = [visibleAirbrakes objectAtIndex: [indexPath indexAtPosition: 1]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {    
    [cell.textLabel setFont: [UIFont fontWithName: @"Helvetica" size: 12.0]];
    [cell setAutoresizesSubviews: YES];
    [cell.textLabel setNumberOfLines: 2];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    user.currentAirbrake = [self.visibleAirbrakes objectAtIndex: [indexPath indexAtPosition: 1]];
}

#pragma mark - Search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    user.searchFilter = searchText;
    [airbrakeTable reloadData];
}

@end
