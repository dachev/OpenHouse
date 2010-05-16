//
//  OpenHousesAppDelegate.h
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "SplashViewController.h"
#import "Database.h"
#import "DiskCache.h"
#import "FlurryAPI.h"

@interface OpenHousesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainController;
    SplashViewController *splashController;
    NSDate *launchTime;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) MainViewController *mainController;
@property (nonatomic, retain) SplashViewController *splashController;
@property (nonatomic, retain) NSDate *launchTime;

@end

