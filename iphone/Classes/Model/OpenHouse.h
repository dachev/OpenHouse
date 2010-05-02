//
//  Callout.h
//  OpenHouses
//
//  Created by blago on 5/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Constants.h"


@interface OpenHouse : NSObject <MKAnnotation> {
	NSString *title;
	NSString *subtitle;
	CLLocationCoordinate2D coordinate;
	
	NSString *propertyType;
	NSString *price;
	NSString *identifier;
	NSString *broker;
	NSString *mlsId;
	NSString *mlsName;
	NSString *agent;
	NSString *providerType;
	NSString *school;
	NSString *schoolDistrict;
	NSString *lotSize;
	NSString *area;
	NSString *bathrooms;
	NSString *year;
	NSString *bedrooms;
	NSString *content;
	NSString *hoaDues;
	NSString *itemLanguage;
	NSString *targetCountry;
	NSString *zoning;
	NSString *itemType;
	NSString *listingType;
	NSString *listingStatus;
	NSString *providerClass;
	NSString *propertyTaxes;
	NSString *model;
	NSString *style;
	NSDate *expirationDate;
	NSDate *begin;
	NSDate *end;
	NSMutableArray *imageLinks;
}

@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, retain) NSString *propertyType;
@property (nonatomic, retain) NSString *price;
@property (nonatomic, retain) NSString *identifier;
@property (nonatomic, retain) NSString *broker;
@property (nonatomic, retain) NSString *mlsId;
@property (nonatomic, retain) NSString *mlsName;
@property (nonatomic, retain) NSString *agent;
@property (nonatomic, retain) NSString *providerType;
@property (nonatomic, retain) NSString *school;
@property (nonatomic, retain) NSString *schoolDistrict;
@property (nonatomic, retain) NSString *lotSize;
@property (nonatomic, retain) NSString *area;
@property (nonatomic, retain) NSString *bathrooms;
@property (nonatomic, retain) NSString *year;
@property (nonatomic, retain) NSString *bedrooms;
@property (nonatomic, retain) NSString *content;
@property (nonatomic, retain) NSString *hoaDues;
@property (nonatomic, retain) NSString *itemLanguage;
@property (nonatomic, retain) NSString *targetCountry;
@property (nonatomic, retain) NSString *zoning;
@property (nonatomic, retain) NSString *itemType;
@property (nonatomic, retain) NSString *listingType;
@property (nonatomic, retain) NSString *listingStatus;
@property (nonatomic, retain) NSString *providerClass;
@property (nonatomic, retain) NSString *propertyTaxes;
@property (nonatomic, retain) NSString *model;
@property (nonatomic, retain) NSString *style;
@property (nonatomic, retain) NSDate *expirationDate;
@property (nonatomic, retain) NSDate *begin;
@property (nonatomic, retain) NSDate *end;
@property (nonatomic, retain) NSMutableArray *imageLinks;

-(id) initWithDictionary:(NSDictionary *)entry;

@end
