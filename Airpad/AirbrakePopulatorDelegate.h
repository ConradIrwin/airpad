//
//  AirbrakePopulatorDelegate.h
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AirbrakeError.h"

@protocol AirbrakePopulatorDelegate <NSObject>
- (void)didActivateAirbrake:(AirbrakeError *) airbrake;
@end
