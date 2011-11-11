//
//  PagedXmlFetcher.m
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "PagedXmlFetcher.h"

@implementation PagedXmlFetcher {
    NSURLConnection* connection;
    NSMutableData* responseData;
}
@synthesize delegate;
@synthesize pageNumber;

- (PagedXmlFetcher *) init {
    self = [super init];
    self->pageNumber = 0;
    return self;
}


- (void) fetchNextPage {
    pageNumber += 1;

    NSAssert(!connection, @"You can't request multiple pages simultaneously!");
    
    NSURL * nextPageUrl = [delegate pagedXmlFetcher:self urlForPage:pageNumber];
    NSLog(@"Fetching %@", nextPageUrl);
    
    if (nextPageUrl) {
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL: nextPageUrl
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                        timeoutInterval:60.0];
        [request setHTTPMethod: @"GET"];

        self->connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        self->responseData = [[NSMutableData alloc] init];

    }
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *e = nil;
    NSData *data = responseData;

    // Set these to nil here so that if didFetchXML wants to it can call fetchNextPage
    self->connection = nil;
    self->responseData = nil;
    
    SMXMLDocument *d= [[SMXMLDocument alloc] initWithAirbrakeData:data error:&e];

    if (e) {
        NSLog(@"got bad XML: %@", [[NSString alloc] initWithData: data encoding: NSASCIIStringEncoding]); 
        [delegate pagedXmlFetcher:self didFailWithError:e];
    } else {
        [delegate pagedXmlFetcher:self didFetchXML:d];
    }
#
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [delegate pagedXmlFetcher:self didFailWithError: error];
}
                               
@end
