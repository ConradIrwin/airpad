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

@implementation AirbrakeListViewController {
    AirbrakeFetcher *fetcher;
    NSString* filter;
}
@synthesize searchBox;
@synthesize airbrakeTable;
@synthesize delegate;
@synthesize fetcher;
@synthesize projectFilter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        filter=@"";
        [self addObserver:self forKeyPath:@"fetcher.airbrakes" options:0 context:@"fetcher"];
        [self addObserver:self forKeyPath:@"projectFilter" options:0 context:@"fetcher"];


    }
    return self;
}

- (void)viewDidUnload
{
    [self setAirbrakeTable:nil];
    [self setSearchBox:nil];
    fetcher = nil;
    filter = nil;
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"fetcher") {
        [airbrakeTable reloadData];
    } else {
        NSLog(@"Received unexpected event!");  
    }
}

- (NSArray*) visibleAirbrakes {
    NSMutableArray *res = [NSMutableArray arrayWithObjects: nil];
    for (AirbrakeError *ab in fetcher.airbrakes) {
        if (([filter isEqualToString: @""] || [ab.title rangeOfString:filter
                                                             options: NSRegularExpressionSearch | NSCaseInsensitiveSearch
                                              ].location != NSNotFound)
            && (
                !projectFilter || !projectFilter.projectId || [projectFilter.projectId integerValue] == ab.projectId
            )) {
            [res addObject:ab];
        }
    }
    return res;
}

#pragma mark - Table

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.visibleAirbrakes count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    AirbrakeError* ab = [self.visibleAirbrakes objectAtIndex: [indexPath indexAtPosition: 1]];
    [cell.textLabel setText: ab.title];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {    
    [cell.textLabel setFont: [UIFont fontWithName: @"Helvetica" size: 12.0]];
    [cell setAutoresizesSubviews: YES];
    [cell.textLabel setNumberOfLines: 2];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AirbrakeError *error = [self.visibleAirbrakes objectAtIndex: [indexPath indexAtPosition: 1]];
    [self.delegate didActivateAirbrake:error];
}

#pragma mark - Search

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self->filter = searchText;
    [airbrakeTable reloadData];
}

@end
