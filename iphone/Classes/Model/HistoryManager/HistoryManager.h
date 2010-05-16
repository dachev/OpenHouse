//
//  HistoryManager.h
//  OpenHouses
//
//  Created by blago on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"
#import "ConnectionManager.h"
#import "CJSONDeserializer.h"
#import "Database.h"
#import "Constants.h"


@interface HistoryManager : NSObject {
	NSMutableDictionary *requests;
}

@property (nonatomic, retain) NSMutableDictionary *requests;

+(HistoryManager *) sharedHistoryManager;
-(void) logLocation:(CLLocation*)loc;

@end
