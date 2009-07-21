//
//  TaggedURLConnection.m
//  Icarus
//
//  Created by blago on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaggedURLConnection.h"


@implementation TaggedURLConnection
@synthesize tag, status;

- (void)dealloc {
	[tag release];
	
	[super dealloc];
}

@end