//
//  PagedXmlFetcher.h
//  Airpad
//
//  Created by Conrad Irwin on 08/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMXMLDocument.h"

@class PagedXmlFetcher;

@protocol PagedXmlFetcherDelegate
- (NSURL*) pagedXmlFetcher:(PagedXmlFetcher*)pagedXmlFetcher urlForPage:(NSInteger)pageNumber;
- (void)   pagedXmlFetcher:(PagedXmlFetcher*)pagedXmlFetcher didFetchXML:(SMXMLDocument *)document;
- (void)   pagedXmlFetcher:(PagedXmlFetcher*)pagedXmlFetcher didFailWithError:(NSError *) error;
@end

@interface PagedXmlFetcher : NSObject <NSURLConnectionDelegate>
@property (nonatomic,assign) id<PagedXmlFetcherDelegate> delegate;
@property (nonatomic,assign) NSInteger pageNumber;
- (void) fetchNextPage;
@end