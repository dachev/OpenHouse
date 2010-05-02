//
//  TaggedRequest.m
//  Icarus
//
//  Created by blago on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TaggedRequest.h"


@implementation TaggedRequest
@synthesize tag, delegate, finishSelector, failSelector;

+(TaggedRequest *) requestWithId:(NSString *)identifier url:(NSString *)urlString {
	NSURL *url = [NSURL URLWithString:urlString];
	TaggedRequest *request = [TaggedRequest requestWithURL:url];
	[request setTag:identifier];
	
	return request;
}

-(void) dealloc {
	[tag release];
	
	[super dealloc];
}

-(void) delegate:(id)d didFinishSelector:(SEL)finishSel didFailSelector:(SEL)failSel {
	delegate       = d;
	finishSelector = finishSel;
	failSelector   = failSel;
}

@end
