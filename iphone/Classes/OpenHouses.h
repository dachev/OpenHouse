//
//  OpenHouses.h
//  OpenHouses
//
//  Created by blago on 6/19/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GData.h"
#import "GDataEntryGoogleBase.h"
#import "GDataFeedGoogleBase.h"
#import "SynthesizeSingleton.h"
#import "OpenHouse.h"
#import "Constants.h"

@protocol OpenHousesApiDelegate
@required
-(void) finishedWithPage:(NSNumber *)page;
-(void) failedWithError:(NSError *)error;
@end



@interface OpenHouses : NSObject {
	NSNumber *totalResults;
	NSNumber *totalPages;
	BOOL pendingRequest;
	
	NSMutableArray *allAnnotations;
	
	id delegate;
}

@property (nonatomic, retain) NSNumber *totalResults;
@property (nonatomic, retain) NSNumber *totalPages;
@property (nonatomic, assign) BOOL pendingRequest;
@property (nonatomic, retain) NSMutableArray *allAnnotations;
@property (nonatomic, assign) id <OpenHousesApiDelegate> delegate;

+(OpenHouses *) sharedOpenHouses;
-(NSArray *) getPage:(NSNumber *)p;
-(BOOL) hasDataForPage:(NSNumber *)p;
-(void) loadMoreData:(CLLocation *) origin;

@end
