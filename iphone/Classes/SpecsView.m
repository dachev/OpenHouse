//
//  SpecsView.m
//  OpenHouses
//
//  Created by blago on 7/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "SpecsView.h"

@interface SpecsView (Private)
-(void) makeLineWithLabel:(NSString *)attr andValue:(NSString *)value;
@end


@implementation SpecsView
@synthesize house, vOffset;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        vOffset = 10.0f;
    }
    return self;
}

-(void) dealloc {
    [house release];
    
    [super dealloc];
}

-(void) setHouse:(OpenHouse *)v {
    [v retain];
    [house release];
    house = v;
    
    
    NSString *time = @"";
    NSString *date = @"";
    NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
    [dateFormatter setDateFormat:OPEN_HOUSE_DATE_TIME];
    time = [time stringByAppendingString:[dateFormatter stringFromDate:[house begin]]];
    time = [time stringByAppendingString:@" - "];
    time = [time stringByAppendingString:[dateFormatter stringFromDate:[house end]]];
    
    [dateFormatter setDateFormat:OPEN_HOUSE_DATE_DAY];
    time = [time stringByAppendingString:@"\n"];
    time = [time stringByAppendingString:[dateFormatter stringFromDate:[house begin]]];
    
    date = [dateFormatter stringFromDate:[house expirationDate]];
    
    [self makeLineWithLabel:@"Price" andValue:[house price]];
    [self makeLineWithLabel:@"Address" andValue:[house title]];
    [self makeLineWithLabel:@"Time" andValue:time];
    [self makeLineWithLabel:@"Description" andValue:[house content]];
    [self makeLineWithLabel:@"Expires" andValue:date];
    [self makeLineWithLabel:@"Prop Taxes" andValue:[house propertyTaxes]];
    [self makeLineWithLabel:@"HOA Dues" andValue:[house hoaDues]];
    [self makeLineWithLabel:@"Bedrooms" andValue:[house bedrooms]];
    [self makeLineWithLabel:@"Bathrooms" andValue:[house bathrooms]];
    [self makeLineWithLabel:@"Area" andValue:[house area]];
    [self makeLineWithLabel:@"Lot Size" andValue:[house lotSize]];
    [self makeLineWithLabel:@"Year" andValue:[house year]];
    [self makeLineWithLabel:@"Prop Type" andValue:[house propertyType]];
    [self makeLineWithLabel:@"Zoning" andValue:[house zoning]];
    [self makeLineWithLabel:@"School" andValue:[house school]];
    [self makeLineWithLabel:@"School Dist" andValue:[house schoolDistrict]];
    [self makeLineWithLabel:@"MLS Id" andValue:[house mlsId]];
    [self makeLineWithLabel:@"MLS Name" andValue:[house mlsName]];
    [self makeLineWithLabel:@"Broker" andValue:[house broker]];
    [self makeLineWithLabel:@"Agent" andValue:[house agent]];
}

-(void) makeLineWithLabel:(NSString *)attr andValue:(NSString *)value {
    UILabel *l11 = [[[UILabel alloc] initWithFrame:CGRectMake(10, vOffset, 80, 20)] autorelease];
    UILabel *l12 = [[[UILabel alloc] initWithFrame:CGRectMake(100, vOffset+1, 210, 0)] autorelease];
    [l11 setText:attr];
    [l12 setText:value];
    [l11 setBackgroundColor:[UIColor clearColor]];
    [l12 setBackgroundColor:[UIColor clearColor]];
    [l11 setTextAlignment:UITextAlignmentRight];
    [l12 setTextAlignment:UITextAlignmentLeft];
    [l11 setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:14.0f]];
    [l12 setFont:[UIFont fontWithName:@"HelveticaNeue" size:14.0f]];
    [l11 setTextColor:[UIColor colorWithRed:101/255.0 green:101/255.0 blue:101/255.0 alpha:1.0]];
    [l12 setTextColor:[UIColor blackColor]];
    [l12 setNumberOfLines:0];
    [l12 sizeToFit];
    
    vOffset += l11.frame.size.height > l12.frame.size.height ?
        l11.frame.size.height :
        l12.frame.size.height;
    vOffset += 2.0f;
    
    [self addSubview:l11];
    [self addSubview:l12];
}


@end
