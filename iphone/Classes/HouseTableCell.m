//
//  HouseTableCell.m
//  OpenHouses
//
//  Created by blago on 6/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HouseTableCell.h"


@implementation HouseTableCell
@synthesize house;

-(void) dealloc {
	[house release];
	
    [super dealloc];
}

-(void) setHouse:(OpenHouse *)v withThumb:(UIImage *)thumb {
	[v retain];
	[house release];
	house = v;
	
	self.textLabel.text = [house title];
    self.detailTextLabel.text = [house subtitle];
	
	[self.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:16]];
	[self.detailTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
	self.imageView.image = thumb;
}

-(void) setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


@end
