//
//  OpenHouses.h
//  OpenHouses
//
//  Created by blago on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "ConnectionManager.h"
#import "CJSONDeserializer.h"
#import "OpenHouse.h"
#import "Constants.h"

@protocol OpenHousesApiDelegate
@required
-(void) finishedWithPage:(NSNumber *)page;
-(void) failedWithError:(NSError *)error;
@end



@interface OpenHouses : NSObject {
    CLLocation *origin;
	NSNumber *totalResults;
	NSNumber *totalPages;
	NSMutableDictionary *requests;
	
	NSMutableArray *allAnnotations;
	
	id delegate;
}

@property (nonatomic, retain) CLLocation *origin;
@property (nonatomic, retain) NSNumber *totalResults;
@property (nonatomic, retain) NSNumber *totalPages;
@property (nonatomic, retain) NSMutableDictionary *requests;
@property (nonatomic, retain) NSMutableArray *allAnnotations;
@property (nonatomic, assign) id <OpenHousesApiDelegate> delegate;

+(OpenHouses *) sharedOpenHouses;
-(NSArray *) getPage:(NSNumber *)p;
-(BOOL) hasDataForPage:(NSNumber *)p;
-(void) loadMoreData;

@end
