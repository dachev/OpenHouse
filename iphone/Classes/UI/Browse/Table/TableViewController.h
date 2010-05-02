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
#import "ConnectionManager.h"
#import "OpenHouse.h"
#import "HouseTableCell.h"


@interface TableViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
	NSArray *currentAnnotations;
	NSMutableArray *thumbnails;
	NSMutableDictionary *requests;
    BOOL noResults;
}

@property (nonatomic, retain) NSArray *currentAnnotations;
@property (nonatomic, retain) NSMutableArray *thumbnails;
@property (nonatomic, retain) NSMutableDictionary *requests;
@property (nonatomic, assign) BOOL noResults;

-(void) showPage:(NSArray *)annotations withOrigin:(CLLocation *)origin;

@end
