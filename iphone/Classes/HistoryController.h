//
//  HistoryController.h
//  OpenHouses
//
//  Created by blago on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Database.h"


@interface HistoryController : UITableViewController <UIActionSheetDelegate> {
    UISegmentedControl *sortButtons;
}

@property (nonatomic, retain) UISegmentedControl *sortButtons;

-(void) sortWithIndex:(int)idx;

@end
