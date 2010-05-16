//
//  HistoryManager.m
//  OpenHouses
//
//  Created by blago on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HistoryManager.h"

@interface HistoryManager (Private)
-(void) getAddressAtLocation:(CLLocation*)loc;
-(void) cancelRequests;
@end

@implementation HistoryManager
SYNTHESIZE_SINGLETON_FOR_CLASS(HistoryManager);
@synthesize requests;

#pragma mark -
#pragma mark Object lifecycle
-(id) init {
	if (self = [super init]) {
		self.requests = [NSMutableDictionary dictionary];
	}
	
	return self;
}

-(void) dealloc {
	[self cancelRequests];
    
    [requests release];
	
	[super dealloc];
}


#pragma mark -
#pragma mark Custom methods
-(void) logLocation:(CLLocation*)loc {
    double lat = loc.coordinate.latitude;
    double lng = loc.coordinate.longitude;
    
    Database *db = [Database sharedDatabase];
    if ([db hasLocationForLat:lat lng:lng] == NO) {
        [db createLocationForLat:lat lng:lng];
        [self getAddressAtLocation:loc];
    }
    else {
        [db updateTimestampForLat:lat lng:lng];
    }
    [db incrementCountForLat:lat lng:lng];
}

-(void) getAddressAtLocation:(CLLocation*)loc {
    double lat = loc.coordinate.latitude;
    double lng = loc.coordinate.longitude;
    
    NSString *url        = [NSString stringWithFormat:GOOGLE_REVERSE_GEOCODING_URL, lat, lng];
    NSString *identifier = [NSString stringWithFormat:@"%f,%f", lat, lng];
    
    if ([self.requests objectForKey:identifier] != nil) {
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
    [self.requests setObject:request forKey:identifier];
        
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    [manager addRequest:request
                withTag:identifier
               delegate:self
      didFinishSelector:@selector(getAddressesFinishWithData:)
        didFailSelector:@selector(getAddressesFailWithData:)
             checkCache:NO
            saveToCache:NO];
}

-(void) cancelRequests {
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    
    for (id key in self.requests) {
        NSURLRequest *request = [self.requests objectForKey:key];
        [manager cancelRequest:request];
    }
}


#pragma mark -
#pragma mark Geocoding API delegates
-(void) getAddressesFinishWithData:(NSDictionary *)data {
    NSUInteger code = [(NSHTTPURLResponse *)[data objectForKey:@"response"] statusCode];
    NSData *payload = [data objectForKey:@"data"];
    NSString *tag   = [data objectForKey:@"tag"];
    
    [self.requests removeObjectForKey:tag];
    
    if(code != 200) {
        return;
    }
    
    NSDictionary *response = [[CJSONDeserializer deserializer] deserializeAsDictionary:payload error:nil];
    if (response == nil) {
        return;
    }
    
    NSString *status = [response objectForKey:@"status"];
    if (status == nil || ![status isEqualToString:@"OK"]) {
        return;
    }
    
    NSArray *results = [response objectForKey:@"results"];
    if (results == nil || [results count] < 1) {
        return;
    }
    
    NSDictionary *result = [results objectAtIndex:0];
    NSString *address = [result valueForKey:@"formatted_address"];
    if (address == nil) {
        return;
    }
    
    NSArray *components = [tag componentsSeparatedByString:@","];
    if ([components count] != 2) {
        return;
    }
    
    NSString *component1 = [components objectAtIndex:0];
    NSString *component2 = [components objectAtIndex:1];
    double lat = [component1 floatValue];
    double lng = [component2 floatValue];
    
    Database *db = [Database sharedDatabase];
    [db updateAddress:address forLat:lat lng:lng];
}

-(void) getAddressesFailWithData:(NSDictionary *)data {
    NSString *tag  = [data objectForKey:@"tag"];
    //NSError *error = [data objectForKey:@"error"];
    
    [self.requests removeObjectForKey:tag];
}

@end
