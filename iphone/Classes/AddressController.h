//
//  AddressController.h
//  OpenHouses
//
//  Created by blago on 8/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "TaggedRequest.h"
#import "ConnectionManager.h"
#import "CJSONDeserializer.h"
#import "AddressResultCell.h"
#import "StatusView.h"


@interface AddressController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate> {
    StatusView *statusView;
    UISearchBar *searchBar;
	NSArray *addresses;
	NSMutableDictionary *requests;
}

@property (nonatomic, retain) StatusView *statusView;
@property (nonatomic, retain) UISearchBar *searchBar;
@property (nonatomic, retain) NSArray *addresses;
@property (nonatomic, retain) NSMutableDictionary *requests;

@end
