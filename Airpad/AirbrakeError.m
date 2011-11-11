//
//  AirbrakeError.m
//  Airpad
//
//  Created by Conrad Irwin on 06/11/2011.
//  Copyright (c) 2011 Rapportive. All rights reserved.
//

#import "AirbrakeError.h"
#import "UserSettings.h"

@implementation AirbrakeError {
    NSURLConnection *connection;
    NSMutableData *responseData;
}
@synthesize details;
@synthesize basics;

-(AirbrakeError *)initWithBasics:(SMXMLElement *)newBasics {
    self = [self init];
    self->basics = newBasics;
    return self;
}

-(NSURL *)airbrakeUrl {
    return [[UserSettings userSettings] urlForAirbrakeWithId:[self airbrakeId]];
}

-(void)fetchDetails {
    
    if(details) {
        return;
    }

    NSAssert(self.airbrakeId, @"Airbrake ID cannot be 0 in fetchDetails");
    NSLog(@"Fetching %@", [self airbrakeUrl]);
    
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[self airbrakeUrl] 
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:60.0];
    [request setHTTPMethod: @"GET"];
    
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self->responseData = [[NSMutableData alloc] init];
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [responseData setLength:0];
}

- (void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [responseData appendData:data];
}

- (void) connectionDidFinishLoading:(NSURLConnection *)connection {    
    NSError *e;
    
    SMXMLDocument *doc = [[SMXMLDocument alloc] initWithAirbrakeData:responseData error:&e];
    if (e) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Sorry, something broke!"
                                   message:[e localizedDescription]
                                  delegate:self
                         cancelButtonTitle:@"OK"
                         otherButtonTitles: nil
         ];
        [alert show];
    }
    self.details = [doc root];
    self->responseData = nil;
}

- (void) putBody:(const char*) body {
    NSMutableURLRequest *request = [NSMutableURLRequest
                                    requestWithURL:[self airbrakeUrl] 
                                    cachePolicy:NSURLRequestUseProtocolCachePolicy
                                    timeoutInterval:60.0];
    [request setHTTPMethod: @"PUT"];
    [request setValue: @"application/xml; charset: utf-8" forHTTPHeaderField: @"Content-Type"];
    [request setHTTPBody: [NSData dataWithBytes: body length:strlen(body)]];
    connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self->responseData = [[NSMutableData alloc] init];
}
- (void) resolve {
    [self putBody: "<group><resolved>true</resolved></group>\n\0"];
}
- (void) reopen{
    [self putBody: "<group><resolved>false</resolved></group>\n\0"];
}


-(NSString*)replaceGemsPathIn:(NSString*)string{
    NSError *e = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@".*/gems/" options:0 error:&e];
    NSAssert(!e, @"That gems regex is valid!");
    NSRange range = NSMakeRange(0, [string length]);
    
    return [re stringByReplacingMatchesInString:string
                                        options:0
                                          range:range
                                   withTemplate:@""];
}
-(NSString*)replaceProjectRootIn:(NSString*)string{
    NSError *e = nil;
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@".*\\[PROJECT_ROOT\\]/" options:0 error:&e];
    NSAssert(!e, @"That project regex is valid!");
    NSRange range = NSMakeRange(0, [string length]);
    return [re stringByReplacingMatchesInString:string
                                        options:0
                                          range:range
                                   withTemplate:@"app/"];
}
- (NSString*)backtrace{    
    SMXMLElement *e = [self.details childNamed:@"backtrace"];
    NSMutableString *s = [[NSMutableString alloc] init];
    NSString *path = nil;
    
    for (SMXMLElement *line in [e childrenNamed:@"line"]) {
        path = [line value];
        path = [self replaceGemsPathIn: path];
        path = [self replaceProjectRootIn: path];
        [s appendString: path];
        [s appendString: @"\n"];
    }
    return s;
}

- (NSString*)title{
    return [[self.basics childNamed:@"error-message"] value];
}

- (NSInteger)airbrakeId{
    return [[[self.basics childNamed:@"id"] value] integerValue];
}

- (bool)isResolved{
    // Use details because it gets refreshed...
    return details && [[[details childNamed:@"resolved"] value] boolValue];
}

- (NSInteger)occurrenceCount{
    return [[[details childNamed:@"notices-count"] value] integerValue];
}

- (NSInteger)projectId{
    return [[[basics childNamed:@"project-id"] value] integerValue];
}

- (NSDate *)earliestSeenAt{
    return [NSDate dateWithISO8601String: [[details childNamed:@"created-at"] value]];
}

- (NSDate *)latestSeenAt{
    return [NSDate dateWithISO8601String: [[details childNamed:@"most-recent-notice-at"] value]];
}

- (double)occurrenceRate{
    NSTimeInterval ti = [[self latestSeenAt] timeIntervalSinceDate:[self earliestSeenAt]];
    if (floor(ti) < 1) {
        return 0;
    }
    return [self occurrenceCount] * 86400.0 / ti;
}
@end
