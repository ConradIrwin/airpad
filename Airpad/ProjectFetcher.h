//
//  ProjectFetcher.h
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedXmlFetcher.h"
#import "AirbrakeProject.h"
#import "AirpadAppDelegate.h"

@interface ProjectFetcher : NSObject <PagedXmlFetcherDelegate>
-(ProjectFetcher *)initWithUser:(AirbrakeUser*)user;
@end
