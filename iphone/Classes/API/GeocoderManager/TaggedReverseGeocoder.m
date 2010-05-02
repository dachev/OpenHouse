//
//  TaggedReverseGeocoder.m
//  OpenHouses
//
//  Created by blago on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaggedReverseGeocoder.h"


@implementation TaggedReverseGeocoder
@synthesize lat, lng;

+(TaggedReverseGeocoder *) requestWithLocation:(CLLocation *)location {
	TaggedReverseGeocoder *request = [[[TaggedReverseGeocoder alloc] initWithCoordinate:location.coordinate] autorelease];
	[request setLat:location.coordinate.latitude];
    [request setLng:location.coordinate.longitude];
	
	return request;
}

@end
