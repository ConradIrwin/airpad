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

- (NSDictionary *) data {
    return [[[UserSettings currentUser] currentAirbrake] data];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self data] count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSInteger count = 0;
    if ([[self data] objectForKey: @"Summary"] && section == count++) {
        return [[self data] objectForKey: @"Summary"];
    } else if ([[self data] objectForKey: @"Paramters"] && section == count++) {
        return [[self data] objectForKey: @"Parameters"];        
    } else if ([[self data] objectForKey: @"Environment"] && section == count++) {
        return [[self data] objectForKey: @"Environment"];
    } else {
        return @"<oops>"; // compiler placation...
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[[self data] objectForKey: [self tableView:nil titleForHeaderInSection:section]] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:@"datacell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"datacell"];
    }
    [[cell textLabel] setText:@"FOOO"];
    [[cell detailTextLabel] setText:@"Bar bar bar bar bar bar"];
    return cell;
}

@end
