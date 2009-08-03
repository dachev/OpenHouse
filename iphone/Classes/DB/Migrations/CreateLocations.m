//
//  CreateLocations.m
//  OpenHouses
//
//  Created by Blagovest Dachev on 7/30/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "CreateLocations.h"


@implementation CreateLocations
- (void) up {
	[self dropTable:@"locations"];
	[self createTable:@"locations" withColumns:
	 [NSArray arrayWithObjects:
	  [FmdbMigrationColumn columnWithColumnName:@"id" columnType:@"integer"],
	  [FmdbMigrationColumn columnWithColumnName:@"lat" columnType:@"string"],
	  [FmdbMigrationColumn columnWithColumnName:@"lng" columnType:@"string"],
	  [FmdbMigrationColumn columnWithColumnName:@"address" columnType:@"string"],
	  [FmdbMigrationColumn columnWithColumnName:@"created_on" columnType:@"double"],
	  [FmdbMigrationColumn columnWithColumnName:@"updated_on" columnType:@"double"],
	  nil]];
    
	[db_ executeUpdate:@"ALTER TABLE locations ADD COLUMN count INTEGER NOT NULL DEFAULT 0"];
    [db_ executeUpdate:@"CREATE INDEX idx_locations_lat ON locations(lat)"];
    [db_ executeUpdate:@"CREATE INDEX idx_locations_lng ON locations(lng)"];
    [db_ executeUpdate:@"CREATE INDEX idx_locations_updated_on ON locations(updated_on)"];
    [db_ executeUpdate:@"CREATE INDEX idx_locations_created_on ON locations(created_on)"];
    [db_ executeUpdate:@"CREATE INDEX idx_locations_count ON locations(count)"];
}

- (void) down {
	[self dropTable:@"locations"];
}
@end
