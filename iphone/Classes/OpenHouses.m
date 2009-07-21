//
//  OpenHouses.m
//  OpenHouses
//
//  Created by blago on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OpenHouses.h"


@interface OpenHouses (Private)
-(GDataServiceGoogleBase *) googleBaseService;
-(NSNumber *) calculatePageFromStartIndex:(NSNumber *)idx;
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
	NSString *beginString = [dateFormatter stringFromDate:beginDate];
	NSString *endString   = [dateFormatter stringFromDate:endDate];
	
	NSString *queryString = [NSString stringWithFormat:OPEN_HOUSES_REQUEST_QUERY, beginString, endString, origin.coordinate.latitude, origin.coordinate.longitude];
	
	
	NSString *googleBaseSnippetsFeed = kGDataGoogleBaseSnippetsFeed;
	NSURL *feedURL = [NSURL URLWithString:googleBaseSnippetsFeed];
	
	GDataQueryGoogleBase *query = [GDataQueryGoogleBase googleBaseQueryWithFeedURL:feedURL];
	[query setGoogleBaseQuery:queryString];
	[query setStartIndex:[[self allAnnotations] count] + 1];
	[query setMaxResults:RESULTS_PER_PAGE_FETCH];
	[query addCustomParameterWithName:@"content" value:@"geocodes,thumbnails"];
	[query addCustomParameterWithName:@"orderby" value:[NSString stringWithFormat:@"[x = location(location): neg(min(dist(x, @%+08.4f%+09.4f)))]", origin.coordinate.latitude, origin.coordinate.longitude]];
	
	GDataServiceGoogleBase *service = [self googleBaseService];
	[service setUserCredentialsWithUsername:nil
								   password:nil];
    
	[service fetchGoogleBaseQuery:query
						 delegate:self
				didFinishSelector:@selector(ticket:finishedWithObject:)
				  didFailSelector:@selector(ticket:failedWithError:)];
	
	[self setPendingRequest:YES];
}


-(GDataServiceGoogleBase *) googleBaseService {
	
	static GDataServiceGoogleBase* service = nil;
	
	if (!service) {
		service = [[GDataServiceGoogleBase alloc] init];
		
		[service setUserAgent:@"OpenHouses-0.1"];
		
		[service setShouldCacheDatedData:YES];
		
		// Note: Though this sample doesn't demonstrate it, GData responses are
		//       typically chunked, so check all returned feeds for "next" links
		//       (use -nextLink method from the GDataLinkArray category on the
		//       links array of GData objects) or call the service's
		//       setShouldFollowNextLinks: method.     
	}
	return service;
}


#pragma mark ---- delegate methods for the GDataQueryGoogleBase class ----
- (void)ticket:(GDataServiceTicket *)ticket finishedWithObject:(GDataObject *)object {
	[self setPendingRequest:NO];
	
	GDataFeedGoogleBase *feed;
	
	if ([object isKindOfClass:[GDataEntryGoogleBase class]]) {
		feed = [GDataFeedGoogleBase googleBaseFeed];
		
		[feed addEntry:(GDataEntryGoogleBase *) object];
	} else {
		feed = (GDataFeedGoogleBase *) object;
	}
	
	NSMutableArray *annotations = [NSMutableArray array];
	for (GDataEntryGoogleBase *entry in [feed entries]) {
		for (GDataGoogleBaseAttribute *attr in [entry entryAttributes]) {
			//NSLog(@"%@ (%@)", [attr name], [attr type]);
		}
		
		OpenHouse *annotation = [[[OpenHouse alloc] initWithGDataEntry:entry] autorelease];
		
		[annotations addObject:annotation];
	}
	
	[self setTotalResults:[feed totalResults]];
	[self setTotalPages:[NSNumber numberWithInt:ceil([[self totalResults] floatValue] / RESULTS_PER_PAGE_DISPLAY)]];
	
	/* Save results */
	NSRange range;
	range.location = [[feed startIndex] intValue] - 1;
	range.length   = [annotations count];
	[[self allAnnotations] insertObjects:annotations atIndexes:[NSIndexSet indexSetWithIndexesInRange:range]];
	
	if ([delegate respondsToSelector: @selector(finishedWithPage:)]) {
		NSNumber *p = [self calculatePageFromStartIndex:[NSNumber numberWithInt:[[feed startIndex] intValue]]];
		[delegate finishedWithPage:p];
    }
}

- (void)ticket:(GDataServiceTicket *)ticket failedWithError:(NSError *)error {
	[self setPendingRequest:NO];

	if ([delegate respondsToSelector: @selector(failedWithError:)]) {
		[delegate failedWithError:error];
	}
		
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
