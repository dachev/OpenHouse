//
//  MainViewController.h
//  OpenHouses
//
//  Created by blago on 6/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BrowseController.h"


@interface MainViewController : UINavigationController {
    BrowseController *browseController;
}

@property (nonatomic, retain) BrowseController *browseController;

@end
