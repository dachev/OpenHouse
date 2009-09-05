//
//  DetailsController.h
//  OpenHouses
//
//  Created by blago on 7/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TaggedRequest.h"
#import "TaggedURLConnection.h"
#import "ConnectionManager.h"
#import "OpenHouse.h"
#import "SpecsView.h"


@interface DetailsController : UIViewController <UIScrollViewDelegate> {
    UIPageControl *pageControl;
	UIScrollView *scrollView;
    SpecsView *specsView;
    OpenHouse *house;
    NSUInteger pages;
	NSMutableDictionary *requests;
	BOOL pageControlUsed;
}

@property (nonatomic, retain) UIPageControl *pageControl;
@property (nonatomic, retain) UIScrollView *scrollView;
@property (nonatomic, retain) SpecsView *specsView;
@property (nonatomic, retain) OpenHouse *house;
@property (nonatomic, assign) NSUInteger pages;
@property (nonatomic, retain) NSMutableDictionary *requests;
@property (nonatomic, assign) BOOL pageControlUsed;

-(void) setHouse:(OpenHouse *)v;

@end
