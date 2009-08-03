//
//  Database.h
//  OpenHouses
//
//  Created by blago on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "Constants.h"
#import "SynthesizeSingleton.h"
#import <sqlite3.h>
#import "FMDatabase.h"
#import "FmdbMigrationManager.h"
#import "CreateLocations.h"


@interface Database : NSObject {
    FMDatabase *fmdb;
}

@property (nonatomic, retain) FMDatabase *fmdb;

+(Database *) sharedDatabase;
-(void) createLocationForLat:(float)latitude lng:(float)longitude;
-(BOOL) hasLocationForAddress:(NSString *)address;
-(BOOL) hasLocationForLat:(float)latitude lng:(float)longitude;
-(NSDictionary *) getLocationForAddress:(NSString *)address;
-(NSDictionary *) getLocationForLat:(float)latitude lng:(float)longitude;
-(void) updateTimestampForLat:(float)latitude lng:(float)longitude;
-(void) updateAddress:(NSString *)address forLat:(float)latitude lng:(float)longitude;
-(void) incrementCountForLat:(float)latitude lng:(float)longitude;
@end
