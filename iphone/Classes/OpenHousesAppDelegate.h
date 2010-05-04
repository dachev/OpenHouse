//
//  OpenHousesAppDelegate.h
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainViewController.h"
#import "Database.h"
#import "DiskCache.h"

@interface OpenHousesAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MainViewController *mainController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MainViewController *mainController;

@end

