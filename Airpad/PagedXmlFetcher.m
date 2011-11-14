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
@synthesize statusCode;

- (id) init {
    self = [super init];
    if (self) {
        self->pageNumber = 0;
    }
    return self;
}

- (void) fetchNextPage {
    pageNumber += 1;
    
    NSURL * nextPageUrl = [delegate pagedXmlFetcher:self urlForPage:pageNumber];
    NSLog(@"Fetching %@", nextPageUrl);
    
    if (nextPageUrl) {
        NSMutableURLRequest *request = [NSMutableURLRequest
                                        requestWithURL: nextPageUrl
                                        cachePolicy:NSURLRequestUseProtocolCachePolicy
                                        timeoutInterval:60.0];
        [request setHTTPMethod: @"GET"];
        [self fetchPageWithRequest: request];
    }
}

- (void) fetchPageWithRequest:(NSMutableURLRequest*)request
{
    NSAssert(!connection, @"You can't request multiple pages simultaneously!");
    self->connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self->responseData = [[NSMutableData alloc] init];
}

#pragma mark – NSURLConnection delegation

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSHTTPURLResponse *)response {
    statusCode = [response statusCode];
    [responseData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [delegate pagedXmlFetcher:self didFailWithError: error];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSError *error = nil;
    NSData *data = responseData;
    SMXMLDocument *document;
    
    // Set these to nil here so that if didFetchXML wants to it can call fetchNextPage
    self->connection = nil;
    self->responseData = nil;
    
    if (statusCode != 200) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:[NSString stringWithFormat: @"Unexpected HTTP-%i response from airbrake.", statusCode] forKey: NSLocalizedDescriptionKey];
        error = [NSError errorWithDomain:@"airbrake-api" code:statusCode userInfo: userInfo];
    } else {
        document = [[SMXMLDocument alloc] initWithAirbrakeData:data error:&error];
    }

    if (error) {
        [delegate pagedXmlFetcher:self didFailWithError:error];
    } else {
        [delegate pagedXmlFetcher:self didFetchXML:document];
    }
}
                               
@end
