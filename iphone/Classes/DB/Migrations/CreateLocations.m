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
	  [FmdbMigrationColumn columnWithColumnName:@"lat" columnType:@"float"],
	  [FmdbMigrationColumn columnWithColumnName:@"lng" columnType:@"float"],
	  [FmdbMigrationColumn columnWithColumnName:@"address" columnType:@"string"],
	  [FmdbMigrationColumn columnWithColumnName:@"created_on" columnType:@"double"],
	  [FmdbMigrationColumn columnWithColumnName:@"updated_on" columnType:@"double"],
	  nil]];
}

- (void) down {
	[self dropTable:@"locations"];
}
@end
