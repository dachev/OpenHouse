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
    
    [Database sharedDatabase];
    
    [window addSubview:[mainController view]];
    [window makeKeyAndVisible];
}

-(void) applicationWillTerminate:(UIApplication *)application {
    [[Database sharedDatabase] release];
	[[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"sefte"];
}

-(void) dealloc {
    [mainController release];
    [window release];
	
    [super dealloc];
}


@end
