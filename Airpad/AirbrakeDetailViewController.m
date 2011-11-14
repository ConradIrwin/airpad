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
@synthesize dataTable;
@synthesize toolbar;
@synthesize resolveSlider;
@synthesize titleLabel;
@synthesize occurrenceLabel;
@synthesize backtraceText;
@synthesize projectMenuButton;
@synthesize listView;
@synthesize viewChanger;

@synthesize user;
@synthesize dataTableDelegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.user = [UserSettings currentUser];
        self.dataTableDelegate = [[DataTableDelegate alloc] init];
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
    NSLog(@"Yup, memory gninraw received!");
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) fixDataTablePosition{
    CGRect visibleArea = [self.view bounds];
    
    visibleArea.origin.y += 193;
    visibleArea.size.height -= 193;
    
    if (0 == viewChanger.selectedSegmentIndex) {
        visibleArea.origin.y += visibleArea.size.height;
    } else {
        [dataTable setHidden: false];
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^(){
                         [dataTable setFrame: visibleArea];
                     }
                     completion:^(BOOL finished) {
                         if (0 == viewChanger.selectedSegmentIndex) {
                             [dataTable setHidden: true];
                         }
                     }
     ];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.dataTable.delegate = dataTableDelegate;
    self.dataTable.dataSource = dataTableDelegate;
    [self.dataTable reloadData];
    [self fixDataTablePosition];
}

- (void)viewDidUnload
{
    [self setToolbar:nil];
    [self setTitleLabel:nil];
    [self setOccurrenceLabel:nil];
    [self setBacktraceText:nil];
    [self setProjectMenuButton:nil];
    [self setResolveSlider:nil];
    [self setDataTable:nil];
    [self setViewChanger:nil];
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

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    // Ensure that the dataTable is still either just below the botom of the screen and hidden,
    // or it's just under the noticescount label.
    [self fixDataTablePosition];
    [[self view] setNeedsDisplay];
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
        
        if (!user.currentAirbrake.hasDetails) {
            [user.currentAirbrake loadDetails];
        }
        
        [backtraceText setText: user.currentAirbrake.backtrace];
        [resolveSlider setOn: [user.currentAirbrake.isResolved boolValue]];
        [titleLabel setText: user.currentAirbrake.errorMessage];
        [occurrenceLabel setText: [self occurrenceDescription]];
        [dataTable reloadData];
        
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
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat: @"http://rapportive.airbrake.io/errors/%@", user.currentAirbrake.airbrakeId]]];
    }
}

- (IBAction)resolveStateChanged:(id)sender {
    if (resolveSlider.on) {
        [user.currentAirbrake resolve];
    } else {
        [user.currentAirbrake reopen];
    }
}

- (IBAction)viewChangerChanged:(id)sender {
    [self fixDataTablePosition];
}
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    if (projectsMenu == popoverController) {
        projectsMenu = nil;
    }
}
@end
