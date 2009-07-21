//
//  SpecsView.h
//  OpenHouses
//
//  Created by blago on 7/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OpenHouse.h"


@interface SpecsView : UIView {
    OpenHouse *house;
    float vOffset;
}

@property (nonatomic, retain) OpenHouse *house;
@property (nonatomic, assign) float vOffset;

@end
