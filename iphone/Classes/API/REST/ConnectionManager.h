//
//  ConnectionManager.h
//  Icarus
//
//  Created by blago on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "TaggedURLConnection.h"
#import "TaggedRequest.h"


@interface ConnectionManager : NSObject {
	NSMutableDictionary *requests;
	NSMutableDictionary *responses;
}

@property (nonatomic, retain) NSMutableDictionary *requests;
@property (nonatomic, retain) NSMutableDictionary *responses;

+(ConnectionManager *) sharedConnectionManager;
-(void) add:(TaggedRequest *)request;

@end
