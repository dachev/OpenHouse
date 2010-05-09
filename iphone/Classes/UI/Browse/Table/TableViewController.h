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
	NSArray *annotations;
    NSMutableArray *timers;
	NSMutableDictionary *requests;
	NSMutableArray *thumbnails;
    BOOL noResults;
}

@property (nonatomic, retain) NSArray *annotations;
@property (nonatomic, retain) NSMutableArray *timers;
@property (nonatomic, retain) NSMutableDictionary *requests;
@property (nonatomic, retain) NSMutableArray *thumbnails;
@property (nonatomic, assign) BOOL noResults;

-(void) showPage:(NSArray *)annotations withOrigin:(CLLocation *)origin;

@end
