//
//  OpenHouses.m
//  OpenHouses
//
//  Created by blago on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OpenHouses.h"


@interface OpenHouses (Private)
-(NSNumber *) calculatePageFromStartIndex:(NSNumber *)idx;
-(void) getHousesFinish:(TaggedURLConnection *)connection withData:(NSData *)data;
-(void) getHousesFail:(TaggedURLConnection *)connection withError:(NSString *)error;
@end

@implementation OpenHouses
SYNTHESIZE_SINGLETON_FOR_CLASS(OpenHouses);
@synthesize totalResults, totalPages, pendingRequest, allAnnotations, delegate;

-(id) init {
	if (self = [super init]) {
		[self setAllAnnotations:[NSMutableArray array]];
		[self setPendingRequest:NO];
	}
	
	return self;
}

-(void) dealloc {
	[totalResults release];
	[totalPages release];
	[allAnnotations release];
	
	[super dealloc];
}

-(void) loadMoreData:(CLLocation *) origin {
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
    NSString *url          = [NSString stringWithFormat:SEARCH_API_REQUEST_URL, offset, records, lat, lng, beginString, endString];
    NSString *identifier   = [NSString stringWithFormat:@"%d", [beginDate timeIntervalSince1970]];
    
    TaggedRequest *request = [TaggedRequest requestWithId:identifier url:url];
    [request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
    [request delegate:self didFinishSelector:@selector(getHousesFinish:withData:) didFailSelector:@selector(getHousesFail:withError:)];
    
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    [manager add:request];
	
	[self setPendingRequest:YES];
}


#pragma mark -
#pragma mark Search API delegates
-(void) getHousesFinish:(TaggedURLConnection *)connection withData:(NSData *)data {
    [self setPendingRequest:NO];
    
    if([connection status] != 200) {
        [self getHousesFail:connection withError:@""];
        return;
    }
    
	NSDictionary *response = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil];
	if (response == nil) {
        [self getHousesFail:connection withError:@""];
        return;
	}
    
	if ([[response objectForKey:@"success"] intValue] != 1) {
        [self getHousesFail:connection withError:@""];
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
    
    //NSLog(@"%@", houses);
}

-(void) getHousesFail:(TaggedURLConnection *)connection withError:(NSString *)error {
     [self setPendingRequest:NO];
    
	/*
     UIAlertView *alert = [[UIAlertView alloc]
     initWithTitle:nil
     message:@"An API error has ocurred. Please try again later."
     delegate:self
     cancelButtonTitle:nil
     otherButtonTitles:@"OK", nil];
     
     [alert show];
     [alert release];
     */
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
	NSUInteger idxBegin = ([p intValue] - 1) * RESULTS_PER_PAGE_DISPLAY;
	NSUInteger idxEnd   = idxBegin + RESULTS_PER_PAGE_DISPLAY - 1;
	
	if ([p intValue] == [totalPages intValue]) {
		idxEnd = [totalResults intValue] % RESULTS_PER_PAGE_DISPLAY - 1;
	}
	
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
