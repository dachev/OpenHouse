//
//  ConnectionManager.m
//  OpenHouses
//
//  Created by blago on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ConnectionManager.h"

@interface ConnectionManager (Private)
@end


@implementation ConnectionManager
SYNTHESIZE_SINGLETON_FOR_CLASS(ConnectionManager);

#pragma mark -
#pragma mark Object lifecycle
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

#pragma mark -
#pragma mark Business logic
-(void) addRequest:(NSURLRequest *)request
        withTag:(NSString *)tag
        delegate:(id)d
        didFinishSelector:(SEL)finishSel
        didFailSelector:(SEL)failSel {
        
        [self addRequest:request
                 withTag:tag
                delegate:d
       didFinishSelector:finishSel
         didFailSelector:failSel
              checkCache:NO
             saveToCache:NO];
}

-(void) addRequest:(NSURLRequest *)request
        withTag:(NSString *)tag
        delegate:(id)d
        didFinishSelector:(SEL)finishSel
        didFailSelector:(SEL)failSel
        checkCache:(BOOL)fromCache
        saveToCache:(BOOL)toCache {
    
    if (fromCache == YES) {
        DiskCache *cache = [DiskCache sharedDiskCache];
        NSData *data = [cache dataForRequest:request];
        
        if (data != nil) {
            if (d && [d respondsToSelector:finishSel]) {
                NSMutableDictionary *info =
                    [NSMutableDictionary
                    dictionaryWithObjects:[NSArray arrayWithObjects:tag, data, nil]
                    forKeys:[NSArray arrayWithObjects:@"tag", @"data", nil]];
            
                [d performSelector:finishSel withObject:info];
            }
            //NSLog(@"hit");
            return;
        }
        else {
            //NSLog(@"miss");
        }
    }
    
	NSURLConnection *connection = [[[NSURLConnection alloc] initWithRequest:request delegate:self] autorelease];
    
    NSNumber *shouldCache = (toCache == YES) ?
        [NSNumber numberWithInt:1] :
        [NSNumber numberWithInt:0];
    
    NSMutableDictionary *info =
        [NSMutableDictionary
         dictionaryWithObjects:[NSArray arrayWithObjects:tag, [NSMutableData data], shouldCache, nil]
         forKeys:[NSArray arrayWithObjects:@"tag", @"data", @"cache", nil]];
    
    NSValue *delegate = [NSValue valueWithNonretainedObject:d];
    NSString *finish  = NSStringFromSelector(finishSel);
    NSString *fail    = NSStringFromSelector(failSel);
    
    NSMutableDictionary *callback =
        [NSMutableDictionary
         dictionaryWithObjects:[NSArray arrayWithObjects:request, delegate, finish, fail, nil]
         forKeys:[NSArray arrayWithObjects:@"request", @"delegate", @"finish", @"fail", nil]];
    
    CFDictionaryAddValue(requests, request, connection);
    CFDictionaryAddValue(connections, connection, info);
    CFDictionaryAddValue(callbacks, connection, callback);
}

-(void) cancelRequest:(NSURLRequest *)request {
    NSURLConnection *connection = (id)CFDictionaryGetValue(requests, request);
    
    if (request) {
 		CFDictionaryRemoveValue(requests, request);
 	}
 	if (connection) {
 		[connection cancel];
 		CFDictionaryRemoveValue(connections, connection);
 		CFDictionaryRemoveValue(callbacks, connection);
 	}
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
    NSURLRequest *request         = (NSURLRequest*)[callback objectForKey:@"request"];
	
	/* Callback */
	id delegate;
    [[callback objectForKey:@"delegate"] getValue:&delegate];
	SEL finish  = NSSelectorFromString([callback objectForKey:@"finish"]);
	if (delegate && [delegate respondsToSelector:finish]) {
		[delegate performSelector:finish withObject:info];
	}
    
    /* save to cache? */
    NSNumber *shouldCache = [info objectForKey:@"cache"];
    if ([shouldCache intValue] == 1) {
        DiskCache *cache = [DiskCache sharedDiskCache];
        NSData *payload = (NSData *)[info objectForKey:@"data"];
        
        [cache storeData:payload ForRequest:request];
        //NSLog(@"save");
    }
	
	/* Clean up */
    if (request) {
 		CFDictionaryRemoveValue(requests, request);
 	}
 	if (connection) {
 		CFDictionaryRemoveValue(connections, connection);
 		CFDictionaryRemoveValue(callbacks, connection);
 	}
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
		[delegate performSelector:fail withObject:info];
	}
	
	/* Clean up */
    if (request) {
 		CFDictionaryRemoveValue(requests, request);
 	}
 	if (connection) {
 		CFDictionaryRemoveValue(connections, connection);
 		CFDictionaryRemoveValue(callbacks, connection);
 	}
}


@end
