//
//  AirbrakeDetailViewController.m
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeDetailViewController.h"
#import "AirbrakeError.h"
#import "ProjectsMenuViewController.h"

@implementation AirbrakeDetailViewController {
    AirbrakeError *currentAirbrake;
    UIPopoverController *projectsMenu;
}
@synthesize toolbar;
@synthesize resolveButton;
@synthesize titleLabel;
@synthesize occurrenceLabel;
@synthesize backtraceText;
@synthesize projectFetcher;
@synthesize projectMenuButton;
@synthesize listView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        currentAirbrake = nil;
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [self setResolveButton:nil];
    [self setTitleLabel:nil];
    [self setOccurrenceLabel:nil];
    [self setBacktraceText:nil];
    [self setProjectMenuButton:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    // We should hide popups when the view is rotated (Programming iOS pp.553, QA1294)
    if (projectsMenu) {
        [projectsMenu dismissPopoverAnimated:YES];
        projectsMenu = nil;
    }
}
#pragma mark - Split View Handling

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    [barButtonItem setTitle: @"Airbrakes"];
    NSArray *arr = [[NSArray arrayWithObject:barButtonItem] arrayByAddingObjectsFromArray:toolbar.items];
    [toolbar setItems: arr animated:YES];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    
    NSMutableArray *arr = [[NSMutableArray alloc] init];    
    for (UIBarButtonItem *item in toolbar.items) {
        if (item != barButtonItem) {
            [arr addObject:item];
        }
    }
    
    [toolbar setItems: arr animated:YES];
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
    if (context == @"airbrake" && object == currentAirbrake) {
        [titleLabel setText: currentAirbrake.title];
        if (currentAirbrake.details) {
            [backtraceText setText: [currentAirbrake backtrace]];
            [resolveButton setEnabled: true];
            if ([currentAirbrake isResolved]) {
                [resolveButton setTitle: @"Resolved" forState: UIControlStateNormal];
            } else {
                [resolveButton setTitle: @"Resolve" forState: UIControlStateNormal];
            }
            [occurrenceLabel setText: [self occurrenceDescription]];
        } else {
            [resolveButton setEnabled:false];
            [resolveButton setTitle: @"Loading…" forState: UIControlStateDisabled];
            [occurrenceLabel setText: @""];
            [backtraceText setText: @""];
        }
        
        
    } else {
        NSLog(@"Got unexpected observer event %@ %@ %@", object, change, context);
    }
}

- (IBAction)resolveClicked:(id)sender {
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

- (IBAction)projectsClicked:(id)sender {
    if (!projectsMenu) {
        ProjectsMenuViewController *menu = [[ProjectsMenuViewController alloc] initWithNibName: @"ProjectsMenuView" bundle:nil];
        projectsMenu = [[UIPopoverController alloc] initWithContentViewController: menu];
        projectsMenu.delegate = self;
        menu.fetcher = projectFetcher;
        menu.delegate = self;
        [projectsMenu presentPopoverFromBarButtonItem:sender
                             permittedArrowDirections:UIPopoverArrowDirectionUp
                                             animated:YES];
        
        // Further clicks on the menu should hide the popup (Programming iOS pp. 554)
        [projectsMenu setPassthroughViews: nil];
    }
}

- (IBAction)openClicked:(id)sender {
    if (currentAirbrake) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat: @"http://rapportive.airbrake.io/errors/%i",currentAirbrake.airbrakeId]]];
    }
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (projectsMenu == popoverController) {
        projectsMenu = nil;
    }
}
- (void)didSelectProject:(AirbrakeProject *)project {
    listView.projectFilter = project;
    [projectMenuButton setTitle: [project name]];
}
@end
