//
//  AirbrakeFetcher.h
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PagedXmlFetcher.h"

@interface AirbrakeFetcher : NSObject <PagedXmlFetcherDelegate>
@property(readonly) NSMutableArray* airbrakes;
@end
