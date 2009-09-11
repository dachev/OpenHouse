//
//  HouseTableCell.h
//  OpenHouses
//
//  Created by blago on 6/23/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenHouse.h"


@interface HouseTableCell : UITableViewCell {
	OpenHouse *house;
}

@property (nonatomic, retain, readonly) OpenHouse *house;

-(void) setHouse:(OpenHouse *)v withThumb:(UIImage *)thumb;

@end
