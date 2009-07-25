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
-(NSString *) makeRangeLabelforBegin:(NSDate *)begin end:(NSDate *)end;
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
    
    NSString *range = [self makeRangeLabelforBegin:[house begin] end:[house end]];
    NSString *date  = [self makeRangeLabelforBegin:[house expirationDate] end:nil];
    
    [self makeLineWithLabel:@"Price" andValue:[house price]];
    [self makeLineWithLabel:@"Address" andValue:[house title]];
    [self makeLineWithLabel:@"Time" andValue:range];
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
    [self makeLineWithLabel:@"Model" andValue:[house model]];
    [self makeLineWithLabel:@"Style" andValue:[house style]];
    [self makeLineWithLabel:@"Zoning" andValue:[house zoning]];
    [self makeLineWithLabel:@"School" andValue:[house school]];
    [self makeLineWithLabel:@"School Dist" andValue:[house schoolDistrict]];
    [self makeLineWithLabel:@"MLS Id" andValue:[house mlsId]];
    [self makeLineWithLabel:@"MLS Name" andValue:[house mlsName]];
    [self makeLineWithLabel:@"Broker" andValue:[house broker]];
    [self makeLineWithLabel:@"Agent" andValue:[house agent]];
}

-(void) makeLineWithLabel:(NSString *)attr andValue:(NSString *)value {
    UILabel *l11 = [[[UILabel alloc] initWithFrame:CGRectMake(10, vOffset+3, 80, 14)] autorelease];
    UILabel *l12 = [[[UILabel alloc] initWithFrame:CGRectMake(100, vOffset, 210, 0)] autorelease];
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
    
    float oDelta = l11.frame.size.height > l12.frame.size.height ?
        20.0f :
        l12.frame.size.height;
    vOffset += oDelta + 7;
    
    [self addSubview:l11];
    [self addSubview:l12];
}

-(NSString *) makeRangeLabelforBegin:(NSDate *)begin end:(NSDate *)end {
    NSString *text = @"";

    if (begin == nil) {
        return @"";
    }
    
    NSDateFormatter *formatter    = [[[NSDateFormatter alloc] init] autorelease];
    if (end == nil) {
        [formatter setDateFormat:OPEN_HOUSE_DATE_DATE];
        return [formatter stringFromDate:begin];
    }
    
    NSCalendar *calendar          = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    int calendarUnits             = kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond;
    NSDateComponents *bcomponents = [calendar components:calendarUnits fromDate:begin];
    NSDateComponents *ecomponents = [calendar components:calendarUnits fromDate:end];
    BOOL isSameDate               = (bcomponents.year  == ecomponents.year) &&
                                    (bcomponents.month == ecomponents.month) &&
                                    (bcomponents.day   == ecomponents.day) ?
                                        YES : NO;
    
    if (!isSameDate) {
        [formatter setDateFormat:OPEN_HOUSE_DATE_DATE];
        text = [text stringByAppendingString:[formatter stringFromDate:begin]];
        text = [text stringByAppendingString:@", "];
        text = [text stringByAppendingString:[formatter stringFromDate:end]];
        
        return text;
    }
    
    if (bcomponents.hour == 0 || ecomponents.hour == 23) {
        [formatter setDateFormat:OPEN_HOUSE_DATE_DATE];
        text = [text stringByAppendingString:[formatter stringFromDate:begin]];
        
        return text;
    }
    
    [formatter setDateFormat:OPEN_HOUSE_DATE_TIME];
    text = [text stringByAppendingString:[formatter stringFromDate:begin]];
    text = [text stringByAppendingString:@" - "];
    text = [text stringByAppendingString:[formatter stringFromDate:end]];
    
    [formatter setDateFormat:OPEN_HOUSE_DATE_DATE];
    text = [text stringByAppendingString:@"\n"];
    text = [text stringByAppendingString:[formatter stringFromDate:begin]];
    
    return text;
}


@end
