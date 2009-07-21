//
//  OpenHousesAppDelegate.m
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "OpenHousesAppDelegate.h"

@implementation OpenHousesAppDelegate

@synthesize window;
@synthesize mainController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [self setMainController:[[MainViewController alloc] initWithNibName:nil bundle:nil]];
	
    // Override point for customization after app launch
    [window addSubview:[mainController view]];
    [window makeKeyAndVisible];
}


- (void)dealloc {
    [mainController release];
    [window release];
	
    [super dealloc];
}


@end
