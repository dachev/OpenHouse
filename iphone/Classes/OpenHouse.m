//
//  Callout.m
//  OpenHouses
//
//  Created by blago on 5/28/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "OpenHouse.h"

@interface OpenHouse (Private)
//-(void) setAttribute:(GDataGoogleBaseAttribute *)attr;
-(NSString *) formatPrice:(NSString *)p;
@end


@implementation OpenHouse
@synthesize title, subtitle, content, coordinate, propertyType, price,
			identifier, broker, mlsId, mlsName, agent, providerType, school,
			schoolDistrict, lotSize, area, bathrooms, year, bedrooms,
			hoaDues, itemLanguage, targetCountry, zoning, itemType,
			listingType, listingStatus, providerClass, propertyTaxes,
			model, style, expirationDate, begin, end, imageLinks;

-(id) initWithDictionary:(NSDictionary *)data {
	if (self = [super init]) {
		[self setPropertyType:@""];
		[self setPrice:@""];
		[self setIdentifier:@""];
		[self setBroker:@""];
		[self setMlsId:@""];
		[self setMlsName:@""];
		[self setAgent:@""];
		[self setProviderType:@""];
		[self setSchool:@""];
		[self setSchoolDistrict:@""];
		[self setLotSize:@""];
		[self setArea:@""];
		[self setBathrooms:@""];
		[self setYear:@""];
		[self setBedrooms:@""];
		[self setHoaDues:@""];
		[self setItemLanguage:@""];
		[self setTargetCountry:@""];
		[self setZoning:@""];
		[self setItemType:@""];
		[self setListingType:@""];
		[self setListingStatus:@""];
		[self setProviderClass:@""];
		[self setPropertyTaxes:@""];
		[self setModel:@""];
		[self setStyle:@""];
		[self setExpirationDate:[NSDate date]];
		[self setBegin:[NSDate date]];
		[self setEnd:[NSDate date]];
		[self setImageLinks:[NSMutableArray array]];
		
		CLLocationCoordinate2D coord;
		coord.latitude  = 0.0f;
		coord.longitude = 0.0f;
		[self setCoordinate:coord];
        
        coordinate.latitude = [[data objectForKey:@"lat"] floatValue];
        coordinate.longitude = [[data objectForKey:@"lng"] floatValue];
        [self setTitle:[data objectForKey:@"addr"]];
        [self setPropertyType:[data objectForKey:@"ptype"]];
        [self setPrice:[data objectForKey:@"price"]];
        [self setIdentifier:[data objectForKey:@"id"]];
        [self setBroker:[data objectForKey:@"broker"]];
        [self setMlsId:[data objectForKey:@"mlsid"]];
        [self setMlsName:[data objectForKey:@"mlsname"]];
        [self setAgent:[data objectForKey:@"agent"]];
        [self setProviderType:[data objectForKey:@"pclass"]];
        [self setSchool:[data objectForKey:@"school"]];
        [self setSchoolDistrict:[data objectForKey:@"schoold"]];
        [self setLotSize:[data objectForKey:@"lot"]];
        [self setArea:[data objectForKey:@"area"]];
        [self setBathrooms:[data objectForKey:@"bathrooms"]];
        [self setBedrooms:[data objectForKey:@"bedrooms"]];
        [self setYear:[data objectForKey:@"year"]];
        [self setHoaDues:[data objectForKey:@"hoa"]];
        [self setZoning:[data objectForKey:@"zoning"]];
        [self setListingType:[data objectForKey:@"ltype"]];
        [self setPropertyTaxes:[data objectForKey:@"ptaxes"]];
        [self setModel:[data objectForKey:@"model"]];
        [self setStyle:[data objectForKey:@"style"]];
        
        [self setYear:[data objectForKey:@"year"]];
        [self setYear:[data objectForKey:@"year"]];
        [self setYear:[data objectForKey:@"year"]];
        
        NSTimeInterval unixDate = [[data objectForKey:@"expdate"] intValue];
        [self setExpirationDate:[NSDate dateWithTimeIntervalSince1970:unixDate]];
        unixDate = [[data objectForKey:@"bdate"] intValue];
        [self setBegin:[NSDate dateWithTimeIntervalSince1970:unixDate]];
        unixDate = [[data objectForKey:@"edate"] intValue];
        [self setEnd:[NSDate dateWithTimeIntervalSince1970:unixDate]];
        
		[self setImageLinks:[data objectForKey:@"images"]];
		
        NSString *c = [data objectForKey:@"description"];
        if ([c isEqualToString:[c uppercaseString]] == YES) {
            c = [c lowercaseString];
        }
        
		[self setContent:c];
		[self setSubtitle:[NSString stringWithFormat:@"%@", price]];
		
		if ([bedrooms isEqualToString:@""] == NO) {
			[self setSubtitle:[NSString stringWithFormat:@"%@, %@ BD", subtitle, bedrooms]];
		}
		if ([bathrooms isEqualToString:@""] == NO) {
			[self setSubtitle:[NSString stringWithFormat:@"%@, %@ BA", subtitle, bathrooms]];
		}
		[self setSubtitle:[NSString stringWithFormat:@"%@, %@", subtitle, propertyType]];

		/* Sort image links so we always use the same as a thumbnail */
		NSArray *fred = [imageLinks sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)];
		[self setImageLinks:[NSArray arrayWithArray:fred]];
    }
        
    return self;
}

-(void) dealloc {
	[title release];
	[subtitle release];
	[propertyType release];
	[price release];
	[identifier release];
	[broker release];
	[mlsId release];
	[mlsName release];
	[agent release];
	[providerType release];
	[school release];
	[schoolDistrict release];
	[lotSize release];
	[area release];
	[bathrooms release];
	[year release];
	[bedrooms release];
	[content release];
	[hoaDues release];
	[itemLanguage release];
	[targetCountry release];
	[zoning release];
	[itemType release];
	[listingType release];
	[listingStatus release];
	[providerClass release];
	[propertyTaxes release];
    [model release];
    [style release];
	[expirationDate release];
	[begin release];
	[end release];
	[imageLinks release];
	
	[super dealloc];
}

//-(void) setAttribute:(GDataGoogleBaseAttribute *)attr {
	/*
	if ([[attr name] isEqualToString:@"latitude"]) {
		coordinate.latitude = [[attr textValue] floatValue];
	}
	else if ([[attr name] isEqualToString:@"longitude"]) {
		coordinate.longitude = [[attr textValue] floatValue];
	}
	else if ([[attr name] isEqualToString:@"location"]) {
		[self setTitle:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"property type"]) {
		[self setPropertyType:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"price"]) {
		[self setPrice:[self formatPrice:[attr textValue]]];
	}
	else if ([[attr name] isEqualToString:@"id"]) {
		[self setIdentifier:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"broker"]) {
		[self setBroker:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"mls listing id"]) {
		[self setMlsId:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"mls name"]) {
		[self setMlsName:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"agent"]) {
		[self setAgent:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"provider type"]) {
		[self setProviderType:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"school"]) {
		[self setSchool:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"school district"]) {
		[self setSchoolDistrict:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"lot size"]) {
		[self setLotSize:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"area"]) {
		[self setArea:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"bathrooms"]) {
		[self setBathrooms:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"year"]) {
		[self setYear:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"bedrooms"]) {
		[self setBedrooms:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"hoa dues"]) {
		[self setHoaDues:[self formatPrice:[attr textValue]]];
	}
	else if ([[attr name] isEqualToString:@"item language"]) {
		[self setItemLanguage:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"target country"]) {
		[self setTargetCountry:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"zoning"]) {
		[self setZoning:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"item type"]) {
		[self setItemType:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"listing type"]) {
		[self setListingType:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"listing status"]) {
		[self setListingStatus:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"provider class"]) {
		[self setProviderClass:[attr textValue]];
	}
	else if ([[attr name] isEqualToString:@"property taxes"]) {
		[self setPropertyTaxes:[self formatPrice:[attr textValue]]];
	}
	else if ([[attr name] isEqualToString:@"expiration date"]) {
		//2009-07-05T07:00:00Z
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:OPEN_HOUSE_DATE_RANGE];
		[self setExpirationDate:[formatter dateFromString:[attr textValue]]];
		[formatter release];
	}
	else if ([[attr name] isEqualToString:@"open house date range"]) {
		//2009-06-28T13:00:00
		NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
		[formatter setDateFormat:OPEN_HOUSE_DATE_RANGE];
		
		NSArray *components = [[attr textValue] componentsSeparatedByString:@" "];
		if ([components count] != 2) {
			return;
		}
		
		[self setBegin:[formatter dateFromString:[components objectAtIndex:0]]];
		[self setEnd:[formatter dateFromString:[components objectAtIndex:1]]];
		
		[formatter release];
	}
	else if ([[attr name] isEqualToString:@"image link"]) {
		[imageLinks addObject:[[attr textValue]
                               stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	else {
		//NSLog(@"%@ (%@): %@", [attr name], [attr type], [attr textValue]);
	}
    */
//}

-(NSString *) formatPrice:(NSString *)p {
	NSString *local = [NSString stringWithString:p];
	
	//if ([local rangeOfString:@" usd"].location != NSNotFound) {
		NSNumber *num = [NSNumber numberWithInt:[local intValue]];
		
		NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
		[numberFormatter setNumberStyle:kCFNumberFormatterDecimalStyle];
		[numberFormatter setGroupingSeparator:@","];
		NSString* commaString = [numberFormatter stringForObjectValue:num];
		[numberFormatter release];

		local = [NSString stringWithFormat:@"$%@", commaString];
	//}
	
	return local;
}

-(NSString *) description {
	NSString *d = @"";
	
	d = [NSString stringWithFormat:@"%@Title: %@\n", d, title];
	d = [NSString stringWithFormat:@"%@Subtitle: %@\n", d, subtitle];
	d = [NSString stringWithFormat:@"%@Content: %@\n", d, content];
	d = [NSString stringWithFormat:@"%@Point: %f, %f\n", d, coordinate.latitude, coordinate.longitude];
	d = [NSString stringWithFormat:@"%@Type: %@\n", d, propertyType];
	d = [NSString stringWithFormat:@"%@Price: %@\n", d, price];
	d = [NSString stringWithFormat:@"%@Identifier: %@\n", d, identifier];
	d = [NSString stringWithFormat:@"%@Broker: %@\n", d, broker];
	d = [NSString stringWithFormat:@"%@MLS Id: %@\n", d, mlsId];
	d = [NSString stringWithFormat:@"%@MLS Name: %@\n", d, mlsName];
	d = [NSString stringWithFormat:@"%@Agent: %@\n", d, agent];
	d = [NSString stringWithFormat:@"%@Provider Type: %@\n", d, providerType];
	d = [NSString stringWithFormat:@"%@School: %@\n", d, school];
	d = [NSString stringWithFormat:@"%@School District: %@\n", d, schoolDistrict];
	d = [NSString stringWithFormat:@"%@Lot Size: %@\n", d, lotSize];
	d = [NSString stringWithFormat:@"%@Area: %@\n", d, area];
	d = [NSString stringWithFormat:@"%@Bathrooms: %@\n", d, bathrooms];
	d = [NSString stringWithFormat:@"%@Year: %@\n", d, year];
	d = [NSString stringWithFormat:@"%@Bedrooms: %@\n", d, bedrooms];
	d = [NSString stringWithFormat:@"%@Hoa Dues: %@\n", d, hoaDues];
	d = [NSString stringWithFormat:@"%@Item Language: %@\n", d, itemLanguage];
	d = [NSString stringWithFormat:@"%@Target Country: %@\n", d, targetCountry];
	d = [NSString stringWithFormat:@"%@Zoning: %@\n", d, zoning];
	d = [NSString stringWithFormat:@"%@Item Type: %@\n", d, itemType];
	d = [NSString stringWithFormat:@"%@Listing Type: %@\n", d, listingType];
	d = [NSString stringWithFormat:@"%@Listing Status: %@\n", d, listingStatus];
	d = [NSString stringWithFormat:@"%@Provider Class: %@\n", d, providerClass];
	d = [NSString stringWithFormat:@"%@Property Taxes: %@\n", d, propertyTaxes];
	d = [NSString stringWithFormat:@"%@Expiration Date: %@\n", d, expirationDate];
	d = [NSString stringWithFormat:@"%@Begin: %@\n", d, begin];
	d = [NSString stringWithFormat:@"%@End: %@\n", d, end];
	d = [NSString stringWithFormat:@"%@Image Links: %@\n", d, imageLinks];
	
	return d;
}

@end