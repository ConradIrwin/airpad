//
//  DataTableDelegate.m
//  Airpad
//
//  Created by Conrad Irwin on 12/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "DataTableDelegate.h"

@implementation DataTableDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 10;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"Hello wold!";
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
