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
-(void) renderMainController;
@end

@implementation OpenHousesAppDelegate

@synthesize window;
@synthesize mainController;
@synthesize splashController;
@synthesize launchTime;
@synthesize initializeTimer;
@synthesize renderTimer;


void uncaughtExceptionHandler(NSException *exception) {
    [FlurryAPI logError:@"Uncaught" message:@"Crash!" exception:exception];
}

-(void) dealloc {
    if ([self.initializeTimer isValid]) {
        [self.initializeTimer invalidate];
    }
    if ([self.renderTimer isValid]) {
        [self.renderTimer invalidate];
    }

    [splashController release];
    [mainController release];
    [launchTime release];
    [initializeTimer release];
    [renderTimer release];
    [window release];
	
    [super dealloc];
}

-(void) applicationDidFinishLaunching:(UIApplication *)application {
    self.splashController = [[[SplashViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [window addSubview:self.splashController.view];
    [window makeKeyAndVisible];
    
    self.launchTime = [NSDate date];
    
    self.initializeTimer = [NSTimer
        scheduledTimerWithTimeInterval:0.01
                                target:self
                              selector:@selector(initializeMainController)
                              userInfo:nil
                               repeats:NO];
}

-(void) initializeMainController {
    [Database sharedDatabase];
    [DiskCache sharedDiskCache];
    
    NSSetUncaughtExceptionHandler(&uncaughtExceptionHandler);
    [FlurryAPI startSession:ANALYTICS_API_KEY];
    
    NSTimeInterval lauchDuration = -[self.launchTime timeIntervalSinceNow];
    if (lauchDuration >= MINIMUM_DURATION_SPLASH_VISIBLE) {
        [self renderMainController];
        return;
    }
    
    NSTimeInterval waitMoreDuration = MINIMUM_DURATION_SPLASH_VISIBLE - lauchDuration;
    self.renderTimer = [NSTimer
        scheduledTimerWithTimeInterval:waitMoreDuration
                                target:self
                              selector:@selector(renderMainController)
                              userInfo:nil
                               repeats:NO];
}

-(void) renderMainController {
    self.mainController = [[[MainViewController alloc] initWithNibName:nil bundle:nil] autorelease];
    [window addSubview:self.mainController.view];
    
    //[self.splashController.view removeFromSuperview];
    //self.splashController = nil;
}

-(void) applicationWillTerminate:(UIApplication *)application {
    [self.mainController.view removeFromSuperview];
    self.mainController = nil;
    
    //[[Database sharedDatabase] release];
    //[[DiskCache sharedDiskCache] release];
}


@end
