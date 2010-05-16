//
//  OpenHousesAppDelegate.m
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "OpenHousesAppDelegate.h"

@interface OpenHousesAppDelegate (Private)
-(void) initializeMainController;
-(void) activateMainController;
@end

@implementation OpenHousesAppDelegate

@synthesize window;
@synthesize mainController;
@synthesize splashController;
@synthesize launchTime;


void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

-(void) dealloc {
    [splashController release];
    [mainController release];
    [launchTime release];
    [window release];
	
    [super dealloc];
}

-(void) applicationDidFinishLaunching:(UIApplication *)application {
    self.splashController = [[[SplashViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [window addSubview:self.splashController.view];
    [window makeKeyAndVisible];
    
    self.launchTime = [NSDate date];
    
    [NSTimer scheduledTimerWithTimeInterval:0.001
                                     target:self
                                   selector:@selector(initializeMainController)
                                   userInfo:nil
                                    repeats:NO];
}

-(void) initializeMainController {
    self.mainController = [[[MainViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    
    [Database sharedDatabase];
    [DiskCache sharedDiskCache];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [FlurryAPI startSession:ANALYTICS_API_KEY];
    
    NSTimeInterval lauchDuration = -[self.launchTime timeIntervalSinceNow];
    if (lauchDuration >= MINIMUM_DURATION_SPLASH_VISIBLE) {
        [self activateMainController];
        return;
    }
    
    NSTimeInterval waitDuration = MINIMUM_DURATION_SPLASH_VISIBLE - lauchDuration;
    [NSTimer scheduledTimerWithTimeInterval:waitDuration
                                     target:self
                                   selector:@selector(activateMainController)
                                   userInfo:nil
                                    repeats:NO];
}

-(void) activateMainController {
    [window addSubview:self.mainController.view];
    
    [self.splashController.view removeFromSuperview];
    self.splashController = nil;
}

-(void) applicationWillTerminate:(UIApplication *)application {
    [[Database sharedDatabase] release];
}


@end
