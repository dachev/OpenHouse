//
//  CalloutButton.m
//  OpenHouses
//
//  Created by blago on 6/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "CalloutButton.h"


@implementation CalloutButton
@synthesize annotation;


- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        // Initialization code
    }
    return self;
}


- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}


- (void)dealloc {
	[annotation release];
	
    [super dealloc];
}


@end
