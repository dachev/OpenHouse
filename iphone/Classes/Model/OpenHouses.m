//
//  OpenHouses.m
//  OpenHouses
//
//  Created by blago on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OpenHouses.h"


@interface OpenHouses (Private)
-(void) cancelRequests;
-(NSNumber *) calculatePageFromStartIndex:(NSNumber *)idx;
@end

@implementation OpenHouses
SYNTHESIZE_SINGLETON_FOR_CLASS(OpenHouses);
@synthesize origin, totalResults, totalPages, requests, allAnnotations, delegate;

-(id) init {
	if (self = [super init]) {
		[self setRequests:[NSMutableDictionary dictionary]];
        
        CLLocation *o = [[[CLLocation alloc] initWithLatitude:0 longitude:0] autorelease];
        [self setOrigin:o];
	}
	
	return self;
}

-(void) dealloc {
	[self cancelRequests];
    
    [origin release];
	[totalResults release];
	[totalPages release];
    [requests release];
	[allAnnotations release];
	
	[super dealloc];
}

-(void) cancelRequests {
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    
	for (id key in requests) {
        NSURLRequest *request = [requests objectForKey:key];
		[manager cancelRequest:request];
    }
}

-(void) setOrigin:(CLLocation *)v {
    [v retain];
    [origin release];
    origin = v;
    
	[self setTotalResults:[NSNumber numberWithInt:0]];
	[self setTotalPages:[NSNumber numberWithInt:0]];
    [self setAllAnnotations:[NSMutableArray array]];
    
	[self cancelRequests];
    [self setRequests:[NSMutableDictionary dictionary]];
}

-(void) loadMoreData {
	NSDate *beginDate = [NSDate date];
	NSDate *endDate   = [NSDate dateWithTimeIntervalSinceNow: 60*60*24*7*2];
	
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setDateFormat:@"yyyy-MM-dd"];
	NSString *beginString  = [dateFormatter stringFromDate:beginDate];
	NSString *endString    = [dateFormatter stringFromDate:endDate];
    int offset             = [[self allAnnotations] count] + 1;
    int records            = RESULTS_PER_PAGE_FETCH;
    float lat              = origin.coordinate.latitude;
    float lng              = origin.coordinate.longitude;
    NSString *url          = [NSString stringWithFormat:SEARCH_API_REQUEST_URL, offset, records, lat, lng, CONFIG_SEARCH_DISTANCE, beginString, endString];
    NSString *identifier   = [NSString stringWithFormat:@"%d", [beginDate timeIntervalSince1970]];
    
	[self cancelRequests];
    [self setRequests:[NSMutableDictionary dictionary]];    
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
    //[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [requests setObject:request forKey:identifier];
    
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    [manager
     addRequest:request
     withTag:identifier
     delegate:self
     didFinishSelector:@selector(getHousesFinishWithData:)
     didFailSelector:@selector(getHousesFailWithData:)
     ];
}


#pragma mark -
#pragma mark Search API delegates
-(void) getHousesFinishWithData:(NSDictionary *)data {
    NSUInteger code = [(NSHTTPURLResponse *)[data objectForKey:@"response"] statusCode];
    NSData *payload = [data objectForKey:@"data"];
    NSString *tag   = [data objectForKey:@"tag"];
    
    [requests removeObjectForKey:tag];
    
    if(code != 200) {
        //[self getHousesFail:connection withError:@"Server error. PLease try again later."];
        return;
    }
    
	NSDictionary *response = [[CJSONDeserializer deserializer] deserializeAsDictionary:payload error:nil];
	if (response == nil) {
        //[self getHousesFail:connection withError:@"Server error. PLease try again later."];
        return;
	}
    
	if ([[response objectForKey:@"success"] intValue] != 1) {
        //[self getHousesFail:connection withError:@"Server error. PLease try again later."];
        return;
	}
    
    NSArray *houses = [response objectForKey:@"houses"];
	NSMutableArray *annotations = [NSMutableArray array];
	for (NSDictionary *house in houses) {
		OpenHouse *annotation = [[[OpenHouse alloc] initWithDictionary:house] autorelease];
		[annotations addObject:annotation];
	}
    
	[self setTotalResults:[NSNumber numberWithInt:[[response objectForKey:@"total"] intValue]]];
	[self setTotalPages:[NSNumber numberWithInt:ceil([[self totalResults] floatValue] / RESULTS_PER_PAGE_DISPLAY)]];
    
	/* Save results */
     NSRange range;
     range.location = [[response objectForKey:@"offset"] intValue] - 1;
     range.length   = [annotations count];
     [[self allAnnotations] insertObjects:annotations atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
     
     if ([delegate respondsToSelector: @selector(finishedWithPage:)]) {
         NSNumber *p = [self calculatePageFromStartIndex:[NSNumber numberWithInt:[[response objectForKey:@"offset"] intValue]]];
         [delegate finishedWithPage:p];
     }
}

-(void) getHousesFailWithData:(NSDictionary *)data {
    NSString *tag  = [data objectForKey:@"tag"];
    NSError *error = [data objectForKey:@"error"];
    
    [requests removeObjectForKey:tag];
     
    if ([delegate respondsToSelector: @selector(failedWithError:)]) {
        [delegate failedWithError:error];
    }
}


#pragma mark --- misc ---
-(NSNumber *) calculatePageFromStartIndex:(NSNumber *)idx  {
	return [NSNumber numberWithInt:floor(([idx floatValue] - 1 + RESULTS_PER_PAGE_DISPLAY) / RESULTS_PER_PAGE_DISPLAY)];
}

-(NSRange) makeRangeForPage:(NSNumber *)p {
	NSRange range;
	range.location = 0;
	range.length   = 0;
	
	NSInteger idx = ([p intValue] - 1) * RESULTS_PER_PAGE_DISPLAY;
	NSInteger len = RESULTS_PER_PAGE_DISPLAY;
	
	if (idx >= [allAnnotations count]) {
		return range;
	}
	if (idx+len > [allAnnotations count]) {
		len = [allAnnotations count] - idx;
	}
	
	range.location = idx;
	range.length   = len;
	
	return range;
}

-(BOOL) hasDataForPage:(NSNumber *)p {
	NSInteger idxBegin = ([p intValue] - 1) * RESULTS_PER_PAGE_DISPLAY;
    
	NSInteger length   = RESULTS_PER_PAGE_DISPLAY;
	if ([p intValue] == [totalPages intValue]) {
		NSInteger partial = [totalResults intValue] % RESULTS_PER_PAGE_DISPLAY;
        length = (partial != 0) ? partial : length;
	}
	NSInteger idxEnd = idxBegin + length - 1;
	
	if (idxBegin >= [allAnnotations count] || idxEnd >= [allAnnotations count]) {
		return NO;
	}
	
	return YES;
}

-(NSArray *) getPage:(NSNumber *)p {
	NSRange range = [self makeRangeForPage:p];
	
	return [allAnnotations subarrayWithRange:range];
}

@end
