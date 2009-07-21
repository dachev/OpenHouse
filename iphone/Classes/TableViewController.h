//
//  TableViewController.h
//  OpenHouses
//
//  Created by blago on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "Constants.h"
#import "TaggedRequest.h"
#import "TaggedURLConnection.h"
#import "ConnectionManager.h"
#import "OpenHouse.h"
#import "HouseTableCell.h"


@interface TableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *currentAnnotations;
	NSMutableArray *thumbnails;
}

@property (nonatomic, retain) NSArray *currentAnnotations;
@property (nonatomic, retain) NSMutableArray *thumbnails;

-(void) showPage:(NSArray *)annotations withOrigin:(CLLocation *)origin;

@end
