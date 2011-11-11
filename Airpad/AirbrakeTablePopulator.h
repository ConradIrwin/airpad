//
//  AirbrakeTablePopulator.h
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AirbrakePopulatorDelegate.h"
@interface AirbrakeTablePopulator : NSObject<UITableViewDataSource,UITableViewDelegate,UISearchBarDelegate>
@property(nonatomic, readonly) NSArray *airbrakes;
@property(nonatomic, assign) id<AirbrakePopulatorDelegate> delegate;
- (AirbrakeTablePopulator *)initWithAirbrakes:(NSArray *) airbrakes;
@property(nonatomic, copy) NSString* filter;

@end