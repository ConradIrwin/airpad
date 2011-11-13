//
//  AirbrakeFetcher.h
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedXmlFetcher.h"
@class AirbrakeUser;
@class AirbrakeError;

@interface AirbrakeFetcher : NSObject <PagedXmlFetcherDelegate>
@property (nonatomic, weak) AirbrakeUser *user;
@property (nonatomic, strong) PagedXmlFetcher *fetcher;
- initWithUser:(AirbrakeUser *)user;
@end
