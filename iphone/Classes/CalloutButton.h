//
//  CalloutButton.h
//  OpenHouses
//
//  Created by blago on 6/11/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Callout.h"


@interface CalloutButton : UIButton {
	Callout *annotation;
}

@property (nonatomic, retain) Callout *annotation;

@end
