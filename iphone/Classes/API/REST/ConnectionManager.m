//
//  ConnectionManager.m
//  OpenHouses
//
//  Created by blago on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConnectionManager.h"


@implementation ConnectionManager
SYNTHESIZE_SINGLETON_FOR_CLASS(ConnectionManager);

-(id) init {
	if (self = [super init]) {
        requests    = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		connections = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
		callbacks   = CFDictionaryCreateMutable(kCFAllocatorDefault, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
	}
    
	return self;
}

-(void) dealloc {
    CFRelease(requests);
    CFRelease(connections);
    CFRelease(callbacks);
	
	[super dealloc];
}

-(void) addRequest:(NSURLRequest *)request withTag:(NSString *)tag delegate:(id)d didFinishSelector:(SEL)finishSel didFailSelector:(SEL)failSel {
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
    NSMutableDictionary *info = [NSMutableDictionary
                                 dictionaryWithObjects:[NSArray arrayWithObjects:tag, [NSMutableData data], nil]
                                 forKeys:[NSArray arrayWithObjects:@"tag", @"data", nil]];
    
    NSValue *delegate = [NSValue valueWithNonretainedObject:d];
    NSString *finish  = NSStringFromSelector(finishSel);
    NSString *fail    = NSStringFromSelector(failSel);
    NSMutableDictionary *callback = [NSMutableDictionary
                                     dictionaryWithObjects:[NSArray arrayWithObjects:request, delegate, finish, fail, nil]
                                     forKeys:[NSArray arrayWithObjects:@"request", @"delegate", @"finish", @"fail", nil]];
    
    CFDictionaryAddValue(requests, request, connection);
    CFDictionaryAddValue(connections, connection, info);
    CFDictionaryAddValue(callbacks, connection, callback);
}

-(void) cancelRequest:(NSURLRequest *)request {
    NSURLConnection *connection = (id)CFDictionaryGetValue(requests, request);
    
    [connection cancel];
    
    CFDictionaryRemoveValue(requests, request);
    CFDictionaryRemoveValue(connections, connection);
    CFDictionaryRemoveValue(callbacks, connection);
}

-(void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    NSMutableDictionary *info = (id)CFDictionaryGetValue(connections, connection);
    
    [info setObject:response forKey:@"response"];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    NSMutableDictionary *info = (id)CFDictionaryGetValue(connections, connection);
    [[info objectForKey:@"data"] appendData:data];
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSMutableDictionary *info     = (id)CFDictionaryGetValue(connections, connection);
    NSMutableDictionary *callback = (id)CFDictionaryGetValue(callbacks, connection);
    NSURLRequest *request         = [callback objectForKey:@"request"];
	
	/* Callback */
	id delegate;
    [[callback objectForKey:@"delegate"] getValue:&delegate];
	SEL finish  = NSSelectorFromString([callback objectForKey:@"finish"]);
	if (delegate && [delegate respondsToSelector:finish]) {
		[delegate performSelector:finish withObject:connection withObject:info];
	}
	
	/* Clean up */
    CFDictionaryRemoveValue(requests, request);
    CFDictionaryRemoveValue(connections, connection);
    CFDictionaryRemoveValue(callbacks, connection);
}

-(void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSMutableDictionary *info     = (id)CFDictionaryGetValue(connections, connection);
    NSMutableDictionary *callback = (id)CFDictionaryGetValue(callbacks, connection);
    NSURLRequest *request         = [callback objectForKey:@"request"];
	
	/* Callback */
	id delegate;
    [[callback objectForKey:@"delegate"] getValue:&delegate];
	SEL fail    = NSSelectorFromString([callback objectForKey:@"fail"]);
	if (delegate && [delegate respondsToSelector:fail]) {
        [info setObject:error forKey:@"error"];
		[delegate performSelector:fail withObject:connection withObject:info];
	}
	
	/* Clean up */
    CFDictionaryRemoveValue(requests, request);
    CFDictionaryRemoveValue(connections, connection);
    CFDictionaryRemoveValue(callbacks, connection);
}


@end
