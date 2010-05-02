//
//  HistoryController.h
//  OpenHouses
//
//  Created by blago on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "Database.h"


@interface HistoryController : UITableViewController <UIActionSheetDelegate> {
    NSArray *locations;
    UISegmentedControl *sortButtons;
    NSInteger sortIdx;
    BOOL noResults;
}

@property (nonatomic, retain) NSArray *locations;
@property (nonatomic, retain) UISegmentedControl *sortButtons;
@property (nonatomic, assign) NSInteger sortIdx;
@property (nonatomic, assign) BOOL noResults;

-(void) sort;

@end
