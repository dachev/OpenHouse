//
//  ImageTableController.h
//  OpenHouses
//
//  Created by blago on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenHouse.h"


@interface ImageTableController : UITableViewController {
    OpenHouse *house;
}

@property (nonatomic, retain) OpenHouse *house;

-(void) setHouse:(OpenHouse *)v;

@end
