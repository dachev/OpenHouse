//
//  Database.m
//  OpenHouses
//
//  Created by blago on 7/30/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "Database.h"

@interface Database (Private)
-(void) createEditableCopyOfDatabaseIfNeeded;
-(void) initializeDatabase;
-(void) performMigrationsOn:(NSString *)file;
@end

@implementation Database
SYNTHESIZE_SINGLETON_FOR_CLASS(Database);
@synthesize fmdb;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) init {
	if (self = [super init]) {
        [self createEditableCopyOfDatabaseIfNeeded];
        [self initializeDatabase];
	}
	
	return self;
}

-(void) dealloc {
    [fmdb close];
    [fmdb release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Location methods
-(void) createLocationForLat:(float)latitude lng:(float)longitude {
    NSString *sql = @"INSERT INTO locations (lat, lng, address, created_on, updated_on) VALUES(?, ?, ?, ?, ?)";
    NSNumber *lat = [NSString stringWithFormat:@"%.5f",latitude];
    NSNumber *lng = [NSString stringWithFormat:@"%.5f",longitude];
    NSDate *now   = [NSDate date];
    
    [fmdb executeUpdate:sql, lat, lng, @"", now, now];
}

-(BOOL) hasLocationForAddress:(NSString *)address {
    return [self getLocationForAddress:address] != nil;
}

-(BOOL) hasLocationForLat:(float)latitude lng:(float)longitude {
    return [self getLocationForLat:latitude lng:longitude] != nil;
}

-(NSDictionary *) getLocationForAddress:(NSString *)address {
	NSMutableDictionary *location = nil;
    
	FMResultSet *rs = [fmdb executeQuery:@"SELECT * FROM locations WHERE address=?", address];
	if ([fmdb hadError]) {
		NSLog(@"Error: %@", [fmdb lastErrorMessage]);
	}
	
    if ([rs next]) {
        NSNumber *lat   = [NSNumber numberWithFloat:[[rs stringForColumn:@"lat"] floatValue]];
        NSNumber *lng   = [NSNumber numberWithFloat:[[rs stringForColumn:@"lng"] floatValue]];
        NSNumber *count = [NSNumber numberWithInt:[rs doubleForColumn:@"count"]];
        location        = [NSMutableDictionary dictionary];
        
        [location setObject:lat forKey:@"lat"];
        [location setObject:lng forKey:@"lng"];
        [location setObject:[rs stringForColumn:@"address"] forKey:@"address"];
        [location setObject:[rs dateForColumn:@"created_on"] forKey:@"created_on"];
        [location setObject:[rs dateForColumn:@"updated_on"] forKey:@"updated_on"];
        [location setObject:count forKey:@"count"];
    }
    [rs close];
	
	return location;
}

-(NSDictionary *) getLocationForLat:(float)latitude lng:(float)longitude {
	NSMutableDictionary *location = nil;
    
    NSNumber *lat = [NSString stringWithFormat:@"%.5f",latitude];
    NSNumber *lng = [NSString stringWithFormat:@"%.5f",longitude];
    
	FMResultSet *rs = [fmdb executeQuery:@"SELECT * FROM locations WHERE lat=? AND lng=?", lat, lng];
	if ([fmdb hadError]) {
		NSLog(@"Error: %@", [fmdb lastErrorMessage]);
	}
	
    if ([rs next]) {
        NSNumber *lat   = [NSNumber numberWithFloat:[[rs stringForColumn:@"lat"] floatValue]];
        NSNumber *lng   = [NSNumber numberWithFloat:[[rs stringForColumn:@"lng"] floatValue]];
        NSNumber *count = [NSNumber numberWithInt:[rs doubleForColumn:@"count"]];
        location        = [NSMutableDictionary dictionary];
        
        [location setObject:lat forKey:@"lat"];
        [location setObject:lng forKey:@"lng"];
        [location setObject:[rs stringForColumn:@"address"] forKey:@"address"];
        [location setObject:[rs dateForColumn:@"created_on"] forKey:@"created_on"];
        [location setObject:[rs dateForColumn:@"updated_on"] forKey:@"updated_on"];
        [location setObject:count forKey:@"count"];
    }
    [rs close];
	
	return location;
}

-(void) updateTimestampForLat:(float)latitude lng:(float)longitude {
    NSString *sql = @"UPDATE locations SET updated_on=? WHERE lat=? AND lng=?";
    NSNumber *lat = [NSString stringWithFormat:@"%.5f",latitude];
    NSNumber *lng = [NSString stringWithFormat:@"%.5f",longitude];
    NSDate *now   = [NSDate date];
    
    [fmdb executeUpdate:sql, now, lat, lng];
}

-(void) updateAddress:(NSString *)address forLat:(float)latitude lng:(float)longitude {
    NSString *sql = @"UPDATE locations SET address=? WHERE lat=? AND lng=?";
    NSNumber *lat = [NSString stringWithFormat:@"%.5f",latitude];
    NSNumber *lng = [NSString stringWithFormat:@"%.5f",longitude];
    
    [fmdb executeUpdate:sql, address, lat, lng];
}

-(void) incrementCountForLat:(float)latitude lng:(float)longitude {
    NSString *sql = @"UPDATE locations SET count=count+1 WHERE lat=? AND lng=?";
    NSNumber *lat = [NSString stringWithFormat:@"%.5f",latitude];
    NSNumber *lng = [NSString stringWithFormat:@"%.5f",longitude];
    NSLog(@"UPDATE locations SET count=count+1 WHERE lat='%@' AND lng='%@'", lat, lng);
    [fmdb executeUpdate:sql, lat, lng];
}

-(void) deleteAllLocations {
    NSString *sql = @"DELETE FROM locations";
    [fmdb executeUpdate:sql];
}


#pragma mark -
#pragma mark Housekeeping
-(void) initializeDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:path]) {
		[self performMigrationsOn:path];
		[self setFmdb:[FMDatabase databaseWithPath:path]];
        //[fmdb setLogsErrors:YES];
        [fmdb open];
	}
	//NSAssert([database open], @"Failed to open database.");
}

-(void) performMigrationsOn:(NSString *)file {
    NSArray *migrations =
    [NSArray arrayWithObjects:
     [CreateLocations migration],
     nil];
    
    [FmdbMigrationManager executeForDatabasePath:file withMigrations:migrations];
}

-(void) createEditableCopyOfDatabaseIfNeeded {
    // First, test for existence.
    BOOL success;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *writableDBPath = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
    success = [fileManager fileExistsAtPath:writableDBPath];
    if (success) return;
    // The writable database does not exist, so copy the default to the appropriate location.
    NSString *defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:DB_NAME];
    success = [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
    if (!success) {
        NSAssert1(0, @"Failed to create writable database file with message '%@'.", [error localizedDescription]);
    }
}

@end
