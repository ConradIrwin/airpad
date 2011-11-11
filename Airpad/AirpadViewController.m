//
//  AirpadViewController.m
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirpadViewController.h"
#import "AirbrakeFetcher.h"
#import <QuartzCore/QuartzCore.h>

@implementation AirpadViewController {
    IBOutlet UILabel *theLabel;
    IBOutlet UITableView *theTable;
    AirbrakeFetcher *fetcher;
    AirbrakeTablePopulator *populator;
    
    AirbrakeError *currentAirbrake;
}

@synthesize theTable;
@synthesize titleLabel;
@synthesize resolveButton;
@synthesize backtraceText;
@synthesize occurrencesLabel;
@synthesize searchBar;
@synthesize populator;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    self->fetcher = [[AirbrakeFetcher alloc] init];
    self.populator = [AirbrakeTablePopulator alloc];
    self.populator = [self.populator initWithAirbrakes: self->fetcher.airbrakes];
    self.populator.delegate = self;
    [self->fetcher addObserver:self forKeyPath:@"airbrakes" options:0 context:@"fetcher"];
    [self->populator addObserver:self forKeyPath:@"filter" options:0 context:@"fetcher"];

    [self.theTable setDataSource: self.populator];
    [self.theTable setDelegate: self.populator];
    [self.searchBar setDelegate: self.populator];
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [self setTitleLabel:nil];
    [self setBacktraceText:nil];
    [self setBacktraceText:nil];
    [self setResolveButton:nil];
    [self setOccurrencesLabel:nil];
    [self setSearchBar:nil];
    [super viewDidUnload];
    self.theTable = nil;
    
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)didActivateAirbrake:(AirbrakeError *)airbrake {
    if (!airbrake.details) {
        [airbrake fetchDetails];
    }
    if (self->currentAirbrake) {
        [self->currentAirbrake removeObserver:self forKeyPath:@"details"];
    }
    self->currentAirbrake = airbrake;
    [airbrake addObserver:self
               forKeyPath:@"details"
                  options:NSKeyValueObservingOptionInitial
                  context:@"airbrake"];
    
}

- (NSString*)prettyDate:(NSDate*)date {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];   
    [fmt setDateStyle:NSDateFormatterMediumStyle];
    [fmt setTimeStyle:NSDateFormatterShortStyle];
    return[fmt stringFromDate:date];
}
- (NSString*)shortDate:(NSDate*)date {
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];   
    [fmt setDateStyle:NSDateFormatterMediumStyle];
    [fmt setTimeStyle:NSDateFormatterNoStyle];
    return[fmt stringFromDate:date];
}
- (NSString*)occurrenceDescription{
    if (currentAirbrake.occurrenceCount == 1) {
        return [NSString stringWithFormat: @"Occured once on %@", [self prettyDate:currentAirbrake.earliestSeenAt]];
    } else if (currentAirbrake.occurrenceCount == 2) {
        return [NSString stringWithFormat: @"Occured twice on %@ and %@",
                                   [self shortDate:currentAirbrake.earliestSeenAt],
                                   [self prettyDate:currentAirbrake.latestSeenAt]];
        
    } else {
        return [NSString stringWithFormat: @"Occured %i times between %@ and %@ (%0.2f/day)",
                                   currentAirbrake.occurrenceCount,
                                   [self shortDate:currentAirbrake.earliestSeenAt],
                                   [self prettyDate:currentAirbrake.latestSeenAt],
                                   currentAirbrake.occurrenceRate];
    }

}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"fetcher") {
        [theTable reloadData];
    } else if (context == @"airbrake" && object == currentAirbrake) {
        [titleLabel setText: currentAirbrake.title];
        if (currentAirbrake.details) {
            [backtraceText setText: [currentAirbrake backtrace]];
            [resolveButton setEnabled: true];
            if ([currentAirbrake isResolved]) {
                [resolveButton setTitle: @"Resolved" forState: UIControlStateNormal];
            } else {
                [resolveButton setTitle: @"Resolve" forState: UIControlStateNormal];
            }
            [occurrencesLabel setText: [self occurrenceDescription]];
        } else {
            [resolveButton setEnabled:false];
            [resolveButton setTitle: @"Loading…" forState: UIControlStateDisabled];
            [occurrencesLabel setText: @""];
            [backtraceText setText: @""];
        }


    } else {
        NSLog(@"Got unexpected observer event %@ %@ %@", object, change, context);
    }
}
- (IBAction)resolveAirbrake:(UIButton *)sender {
    if (currentAirbrake) {
        if ([currentAirbrake isResolved]) {
            [currentAirbrake reopen];
            [resolveButton setTitle: @"Undoing…" forState: UIControlStateDisabled];
        } else {
            [currentAirbrake resolve];
            [resolveButton setTitle:@"Resolving…" forState: UIControlStateDisabled];
        }
        [resolveButton setEnabled:false];
    }
}
@end
