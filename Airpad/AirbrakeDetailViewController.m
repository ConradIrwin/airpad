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
#import "UserSettings.h"


@implementation AirbrakeDetailViewController {
    UIPopoverController *projectsMenu;
    UIPopoverController *airbrakesMenu;
}
@synthesize toolbar;
@synthesize resolveButton;
@synthesize resolveSlider;
@synthesize titleLabel;
@synthesize occurrenceLabel;
@synthesize backtraceText;
@synthesize projectMenuButton;
@synthesize listView;

@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.user = [UserSettings currentUser];
        [self.user addObserver:self forKeyPath:@"currentAirbrake.details" options:NSKeyValueObservingOptionInitial context:@"currentAirbrake"];
        [self.user addObserver:self forKeyPath:@"projectFilter" options: NSKeyValueObservingOptionInitial context: @"projectFilter"];
    }
    return self;
}

- (void)dealloc
{
    [self.user removeObserver: self forKeyPath: @"currentAirbrake.details"];
    [self.user removeObserver: self forKeyPath: @"projectFilter"];
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
    [self setResolveSlider:nil];
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
        // Animation looks terrible here.
        [projectsMenu dismissPopoverAnimated:NO];
        projectsMenu = nil;
    }
}
#pragma mark - Split View Handling

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)pc {
    [barButtonItem setTitle: @"Airbrakes"];
    
    // Allow people to click the resolve button with the menu open.
    // (as a side effect, disallow clicks on other popover menus when the menu is opened).
    NSArray *arr = [[NSArray arrayWithObject:barButtonItem] arrayByAddingObjectsFromArray:toolbar.items];
    airbrakesMenu = pc;
    [toolbar setItems: arr animated:YES];
}

- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem {
    airbrakesMenu = nil;
    NSMutableArray *arr = [[NSMutableArray alloc] init];    
    for (UIBarButtonItem *item in toolbar.items) {
        if (item != barButtonItem) {
            [arr addObject:item];
        }
    }
    
    [toolbar setItems: arr animated:YES];
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
    if ([user.currentAirbrake.noticesCount integerValue] == 1) {
        return [NSString stringWithFormat: @"Occured once on %@", [self prettyDate:user.currentAirbrake.earliestSeenAt]];
    } else if ([user.currentAirbrake.noticesCount integerValue] == 2) {
        return [NSString stringWithFormat: @"Occured twice on %@ and %@",
                [self shortDate:user.currentAirbrake.earliestSeenAt],
                [self prettyDate:user.currentAirbrake.latestSeenAt]];
        
    } else {
        return [NSString stringWithFormat: @"Occured %@ times between %@ and %@ (%0.2f/day)",
                user.currentAirbrake.noticesCount,
                [self shortDate:user.currentAirbrake.earliestSeenAt],
                [self prettyDate:user.currentAirbrake.latestSeenAt],
                user.currentAirbrake.occurrenceRate];
    }
    
}
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"currentAirbrake") {
        
        if (user.currentAirbrake.hasDetails) {
            [backtraceText setText: user.currentAirbrake.backtrace];
            [resolveButton setEnabled: true];
            if ([user.currentAirbrake.isResolved boolValue]) {
                [resolveButton setTitle: @"Resolved" forState: UIControlStateNormal];
            } else {
                [resolveButton setTitle: @"Resolve" forState: UIControlStateNormal];
            }
        } else {
            [user.currentAirbrake loadDetails];
            [resolveButton setEnabled:false];
            [resolveButton setTitle: @"Loading…" forState: UIControlStateDisabled];
            [backtraceText setText: @""];
        }
        
        [titleLabel setText: user.currentAirbrake.errorMessage];
        [occurrenceLabel setText: [self occurrenceDescription]];        
        
    } else if (context == @"projectFilter") {
        if (!user.projectFilter) {
            [projectMenuButton setTitle: @"All Projects"];
        } else {
            [projectMenuButton setTitle: [user.projectFilter nameWithFallback]];
        }
        if (projectsMenu) {
            [projectsMenu dismissPopoverAnimated:YES];
            projectsMenu = nil;
        }
    }
}

- (IBAction)resolveClicked:(id)sender {
    if (user.currentAirbrake) {
        if ([user.currentAirbrake.isResolved boolValue]) {
            [user.currentAirbrake reopen];
            [resolveButton setTitle: @"Undoing…" forState: UIControlStateDisabled];
        } else {
            [user.currentAirbrake resolve];
            [resolveButton setTitle: @"Resolving…" forState: UIControlStateDisabled];
        }
        [resolveButton setEnabled:false];
    }
}

- (IBAction)projectsClicked:(id)sender {
    if (airbrakesMenu) {
        [airbrakesMenu dismissPopoverAnimated:NO];
    }
    ProjectsMenuViewController *menu = [[ProjectsMenuViewController alloc] initWithNibName: @"ProjectsMenuView" bundle:nil];
    projectsMenu = [[UIPopoverController alloc] initWithContentViewController: menu];
    projectsMenu.delegate = self;
    menu.popoverController = projectsMenu;
    [projectsMenu presentPopoverFromBarButtonItem:sender
                         permittedArrowDirections:UIPopoverArrowDirectionUp
                                         animated:YES];
    
    // Further clicks on the menu should hide the popup (Programming iOS pp. 554)
    [projectsMenu setPassthroughViews: nil];
}

- (IBAction)openClicked:(id)sender {
    if (user.currentAirbrake) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat: @"http://rapportive.airbrake.io/errors/%i", user.currentAirbrake.airbrakeId]]];
    }
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (projectsMenu == popoverController) {
        projectsMenu = nil;
    }
}
@end
