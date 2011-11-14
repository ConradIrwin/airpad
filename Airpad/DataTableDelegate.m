//
//  DataTableDelegate.m
//  Airpad
//
//  Created by Conrad Irwin on 12/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "DataTableDelegate.h"
#import "UserSettings.h"

@implementation DataTableDelegate

- (NSArray *) data {
    return [[[UserSettings currentUser] currentAirbrake] data];
}

- (NSArray *) pairAtIndexPath:(NSIndexPath *)indexPath {
    return [[[[self data] objectAtIndex: [indexPath indexAtPosition: 0]] objectAtIndex: 1] objectAtIndex: [indexPath indexAtPosition: 1]];
}

- (UIFont *) font {
    static UIFont *font;
    if (!font) {
        return [UIFont fontWithName: @"Helvetica" size: 12.0];
    }
    return font;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self data] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [[[self data] objectAtIndex: section] objectAtIndex: 0];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger ret = [[[[self data] objectAtIndex: section] objectAtIndex: 1] count];
    return ret;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *value = [[self pairAtIndexPath: indexPath] objectAtIndex: 1];
    
    CGFloat min = [[self font] lineHeight] * 2.0;

    CGFloat desired = [value sizeWithFont: [self font] constrainedToSize: CGSizeMake(420.0, 500.0) lineBreakMode:UILineBreakModeWordWrap].height + 5.0;
    
    return MAX(min, desired);
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *sectionData = [[[self data] objectAtIndex: [indexPath indexAtPosition: 0]] objectAtIndex: 1];
    NSArray *keyValue = [sectionData objectAtIndex: [indexPath indexAtPosition: 1]];
    
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"datacell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"datacell"];
    }
    [[cell textLabel] setText:[keyValue objectAtIndex:0]];
    [[cell detailTextLabel] setText:[keyValue objectAtIndex:1]];
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell.detailTextLabel setFont: [UIFont fontWithName: @"Helvetica" size: 12.0]];
    [cell.detailTextLabel setNumberOfLines: 0];
    [cell.detailTextLabel setLineBreakMode:UILineBreakModeWordWrap];
}

@end
