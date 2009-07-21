//
//  BrowseController.h
//  OpenHouses
//
//  Created by blago on 6/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"
#import "TableViewController.h"
#import "DetailsController.h"
#import "OpenHouse.h"
#import "OpenHouses.h"


@interface BrowseController : UIViewController <OpenHousesApiDelegate> {
    MapViewController   *mapController;
    TableViewController *tableController;
    UIViewController *activeController;
	
	NSNumber *page;
	CLLocation *origin;
	NSArray *currentAnnotations;
	
	UISegmentedControl *navButtons;
	UIToolbar *toolbar;
}

@property (nonatomic, retain) MapViewController *mapController;
@property (nonatomic, retain) TableViewController *tableController;
@property (nonatomic, retain) UIViewController *activeController;
@property (nonatomic, retain) NSNumber *page;
@property (nonatomic, retain) CLLocation *origin;
@property (nonatomic, retain) NSArray *currentAnnotations;
@property (nonatomic, retain) UISegmentedControl *navButtons;
@property (nonatomic, retain) UIToolbar *toolbar;

@end
