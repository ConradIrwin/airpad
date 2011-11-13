//
//  ProjectsMenuViewController.m
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "ProjectsMenuViewController.h"
#import "UserSettings.h"

@implementation ProjectsMenuViewController
@synthesize theTable;
@synthesize popoverController;
@synthesize user;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        user = [UserSettings currentUser];
        [user addObserver:self forKeyPath:@"projects" options:NSKeyValueObservingOptionInitial context:@"projects"];
    }
    return self;
}

- (NSArray*)projects
{
    return [user sortedProjects];
}

- (AirbrakeProject*) projectAtIndex:(NSInteger)index
{
    AirbrakeProject *project = [[self projects] objectAtIndex:index];
    NSAssert(project, @"nil project at index %i", index);
    return project;    
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == @"projects") {
        [self.theTable reloadData];
    }
}

- (void)viewDidLayoutSubviews {
    [popoverController setPopoverContentSize:[self.theTable contentSize] animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (0 == section) {
        return 1;
    } else {
        return [[self projects] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    
    if (0 == [indexPath indexAtPosition:0]) {
        [cell.textLabel setText:@"All Projects"];
    } else {
        [cell.textLabel setText: [[self projectAtIndex:[indexPath indexAtPosition:1]] nameWithFallback]];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (0 == [indexPath indexAtPosition:0]) {
        user.projectFilter = nil;
    } else {        
        user.projectFilter = [self projectAtIndex:[indexPath indexAtPosition:1]];
    }
}

#pragma mark - View lifecycle


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [self setTheTable:nil];
    [super viewDidUnload];

    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
- (void)dealloc {
    [user removeObserver:self forKeyPath:@"projects"];
    user = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}
@end
