//
//  OpenHousesViewController.h
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>
#import "Constants.h"
#import "OpenHouse.h"

@interface MapViewController : UIViewController <MKMapViewDelegate> {
	NSArray *annotations;
	MKMapView *mapView;
}

@property (nonatomic, retain) NSArray *annotations;
@property (nonatomic, retain) MKMapView *mapView;

-(void) setLocation:(CLLocation *)loc;
-(void) showPage:(NSArray *)annotations withOrigin:(CLLocation *)origin;
-(void) showCallout:(OpenHouse *)house;

@end

