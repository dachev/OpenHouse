//
//  ConnectionManager.m
//  Icarus
//
//  Created by blago on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConnectionManager.h"


@implementation ConnectionManager
SYNTHESIZE_SINGLETON_FOR_CLASS(ConnectionManager);
@synthesize requests, responses;

-(id) init {
	if (self = [super init]) {
		[self setRequests:[NSMutableDictionary dictionary]];
		[self setResponses:[NSMutableDictionary dictionary]];
	}

	return self;
}

-(void) dealloc {
	[requests release];
	[responses release];
	
	[super dealloc];
}

-(void) add:(TaggedRequest *)request {
	TaggedURLConnection *connection = [[TaggedURLConnection alloc] initWithRequest:request delegate:self];
	[connection setTag:[request tag]];
	
	[requests setObject:request forKey:[request tag]];
	[responses setObject:[NSMutableData data] forKey:[request tag]];
}

-(void) connection:(TaggedURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [connection setStatus:[(NSHTTPURLResponse *)response statusCode]];
}

-(void) connection:(TaggedURLConnection *)connection didReceiveData:(NSData *)data {
	NSMutableData *response = [responses objectForKey:[connection tag]];
	
    [response appendData:data];
}

-(void) connectionDidFinishLoading:(TaggedURLConnection *)connection {
	TaggedRequest *request  = [requests objectForKey:[connection tag]];
	NSMutableData  *response = [responses objectForKey:[connection tag]];
	
	/* Callback */
	id delegate        = [request delegate];
	SEL finishSelector = [request finishSelector];
	if (delegate && finishSelector && [delegate respondsToSelector:finishSelector]) {
		[delegate performSelector:finishSelector withObject:connection withObject:response];
	}
	
	/* Clean up */
	[requests removeObjectForKey:[connection tag]];
	[responses removeObjectForKey:[connection tag]];
	
	[connection release];
}

-(void) connection:(TaggedURLConnection *)connection didFailWithError:(NSError *)error {
	TaggedRequest *request  = [requests objectForKey:[connection tag]];
	
	/* Callback */
	id delegate      = [request delegate];
	SEL failSelector = [request failSelector];
	if (delegate && failSelector && [delegate respondsToSelector:failSelector]) {
		[delegate performSelector:failSelector withObject:connection withObject:[error localizedDescription]];
	}
	
	/* Clean up */
	[requests removeObjectForKey:[connection tag]];
	[responses removeObjectForKey:[connection tag]];
	
	[connection release];
}

@end
