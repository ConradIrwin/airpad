//
//  AirbrakeTablePopulator.m
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeTablePopulator.h"
#import "AirbrakeError.h"

@implementation AirbrakeTablePopulator {
    NSMutableArray *_airbrakes;
}
@synthesize airbrakes=_airbrakes;
@synthesize delegate;
@synthesize filter;

- (AirbrakeTablePopulator *)initWithAirbrakes:(NSMutableArray *)airbrakes {
    self = [super init];
    self->_airbrakes = airbrakes;
    self->filter = @"";
    return self;
}

- (AirbrakeTablePopulator *)init {
    return [self initWithAirbrakes: [[NSArray alloc] initWithObjects:nil]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSArray*) visibleAirbrakes {
    NSMutableArray *res = [NSMutableArray arrayWithObjects: nil];
    for (AirbrakeError *ab in self.airbrakes) {
        if ([filter isEqualToString: @""] || [ab.title rangeOfString:filter
                                                      options: NSRegularExpressionSearch | NSCaseInsensitiveSearch
                                             ].location != NSNotFound) {
            [res addObject:ab];
        }
    }
    return res;
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

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    self.filter = searchText;
}
@end
