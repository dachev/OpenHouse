//
//  BrowseController.h
//  OpenHouses
//
//  Created by blago on 6/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "FlurryAPI.h"
#import "Database.h"
#import "OpenHouses.h"
#import "TaggedReverseGeocoder.h"
#import "MapViewController.h"
#import "TableViewController.h"
#import "DetailsController.h"
#import "ImageTableController.h"
#import "AddressController.h"
#import "HistoryController.h"
#import "StatusView.h"
#import "OpenHouse.h"


@interface BrowseController : UIViewController <OpenHousesApiDelegate,
                                                UIActionSheetDelegate,
                                                UINavigationControllerDelegate,
                                                CLLocationManagerDelegate> {
    MapViewController   *mapController;
    TableViewController *tableController;
    UIViewController *activeController;
	
	NSNumber *page;
	CLLocation *origin;
	NSArray *annotations;
    MKReverseGeocoder *geoCoder;
	
    StatusView *statusView;
	UISegmentedControl *navButtons;
    UIImage *mapIconImage;
    UIImage *listIconImage;
    
    BOOL locationPendingSearch;
    CLLocationManager *locationManager;
}

@property (nonatomic, retain) MapViewController *mapController;
@property (nonatomic, retain) TableViewController *tableController;
@property (nonatomic, retain) UIViewController *activeController;
@property (nonatomic, retain) NSNumber *page;
@property (nonatomic, retain) CLLocation *origin;
@property (nonatomic, retain) NSArray *annotations;
@property (nonatomic, retain) MKReverseGeocoder *geoCoder;
@property (nonatomic, retain) StatusView *statusView;
@property (nonatomic, retain) UISegmentedControl *navButtons;
@property (nonatomic, retain) UIImage *mapIconImage;
@property (nonatomic, retain) UIImage *listIconImage;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) BOOL locationPendingSearch;

@end



