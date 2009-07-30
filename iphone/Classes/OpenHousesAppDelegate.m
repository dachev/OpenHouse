//
//  OpenHousesAppDelegate.m
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "OpenHousesAppDelegate.h"

@interface OpenHousesAppDelegate (Private)
- (void) createEditableCopyOfDatabaseIfNeeded;
- (void) performMigrationsOn:(NSString *)file;
- (void) initializeDatabase;
@end

@implementation OpenHousesAppDelegate

@synthesize window;
@synthesize mainController;


-(void) applicationDidFinishLaunching:(UIApplication *)application {
    [self setMainController:[[MainViewController alloc] initWithNibName:nil bundle:nil]];
	
    [self createEditableCopyOfDatabaseIfNeeded];
    [self initializeDatabase];
    
    [window addSubview:[mainController view]];
    [window makeKeyAndVisible];
}

-(void) applicationWillTerminate:(UIApplication *)application {
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sefte"];
	//[database close];
}

- (void) createEditableCopyOfDatabaseIfNeeded {
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

-(void) initializeDatabase {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:DB_NAME];
	
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if([fileManager fileExistsAtPath:path]) {
		[self performMigrationsOn:path];
		//[self setDatabase:[FMDatabase databaseWithPath:path]];
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

-(void) dealloc {
    [mainController release];
    [window release];
	
    [super dealloc];
}


@end
