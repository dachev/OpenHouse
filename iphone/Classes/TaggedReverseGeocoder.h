//
//  TaggedReverseGeocoder.h
//  OpenHouses
//
//  Created by blago on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>


@interface TaggedReverseGeocoder : MKReverseGeocoder {
    float lat;
    float lng;
}

@property (nonatomic, assign) float lat;
@property (nonatomic, assign) float lng;

+(TaggedReverseGeocoder *) requestWithLocation:(CLLocation *)location;

@end
