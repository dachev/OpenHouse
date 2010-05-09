//
//  OpenHousesAppDelegate.m
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "OpenHousesAppDelegate.h"

@interface OpenHousesAppDelegate (Private)
@end

@implementation OpenHousesAppDelegate

@synthesize window;
@synthesize mainController;


-(void) dealloc {
    [mainController release];
    [window release];
	
    [super dealloc];
}

-(void) applicationDidFinishLaunching:(UIApplication *)application {
    [self setMainController:[[MainViewController alloc] initWithNibName:nil bundle:nil]];
    
    [Database sharedDatabase];
    [DiskCache sharedDiskCache];
    
    [FlurryAPI startSession:@"H2S9NJ6VW43CXGKY26LT"];
    
    [window addSubview:[mainController view]];
    [window makeKeyAndVisible];
}

-(void) applicationWillTerminate:(UIApplication *)application {
    [[Database sharedDatabase] release];
}


@end
