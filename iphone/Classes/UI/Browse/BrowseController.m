//
//  BrowseController.m
//  OpenHouses
//
//  Created by blago on 6/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BrowseController.h"

@interface NSString (Custom)
+(NSString *) encodeURIComponent: (NSString *) url;
@end

@interface BrowseController (Private)
-(void) setOriginAtLat:(float)lat lng:(float)lng;
-(void) getPage:(NSNumber *)p;
-(void) showPage:(NSNumber *)p;
-(void) updateNavButtons;
-(void) toggleView;
-(void) selectAction:(id)sender;
-(NSDictionary *) makeDictionaryWithLat:(double)lat lng:(double)lng;
-(NSDictionary *) makeDictionaryWithCLLocation:(CLLocation *)location;
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation;
-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error;
-(void) showAlertWithText:(NSString *)text;
@end


@implementation BrowseController
@synthesize mapController, tableController, activeController, page, origin, annotations,
            geoCoder, statusView, navButtons, mapIconImage, listIconImage, locationManager,
            locationPendingSearch;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self setAnnotations:[NSArray array]];
		[self setPage:[NSNumber numberWithInt:0]];
		
		/* Initialize nav buttons */
		NSArray *navItems = [NSArray arrayWithObjects:[UIImage imageNamed:@"down.png"], [UIImage imageNamed:@"up.png"], nil];
		[self setNavButtons:[[[UISegmentedControl alloc] initWithItems:navItems] autorelease]];
		[navButtons addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
		
		[navButtons setMomentary:YES];
		[navButtons setSegmentedControlStyle:UISegmentedControlStyleBar];
		
		[navButtons setWidth:40 forSegmentAtIndex:0];
		[navButtons setWidth:40 forSegmentAtIndex:1];
		[navButtons setEnabled:NO forSegmentAtIndex:0];
		[navButtons setEnabled:NO forSegmentAtIndex:1];
		
		UIBarButtonItem *barNavButton = [[UIBarButtonItem alloc] initWithCustomView:navButtons];
		[[self navigationItem] setRightBarButtonItem:barNavButton];
		[barNavButton release];
		
        [self setListIconImage:[UIImage imageNamed:@"list.png"]];
        [self setMapIconImage:[UIImage imageNamed:@"map.png"]];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"last_location_update"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedHouseCallback:) name:@"selectedHouse" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedLocationCallback:) name:@"selectedLocationFromHistory" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedAddressCallback:) name:@"selectedAddressFromGeocoding" object:nil];
    }
    return self;
}

-(void) dealloc {
	[mapController release];
	[tableController release];
	[activeController release];
	[page release];
	[origin release];
	[annotations release];
    [geoCoder release];
    [statusView release];
	[navButtons release];
	[mapIconImage release];
	[listIconImage release];
    [locationManager release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Standard UIViewController stuff
-(void) loadView {
	[self setView:[[[UIView alloc] initWithFrame:CGRectZero] autorelease]];
	
	/* Create browse controllers */
	[self setMapController:[[[MapViewController alloc] initWithNibName:nil bundle:nil] autorelease]];
	[self setActiveController:mapController];
	[[self view] addSubview:[mapController view]];
	
	[self setTableController:[[[TableViewController alloc] initWithStyle:UITableViewStylePlain] autorelease]];
	
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
	[openHouses setDelegate:self];
 	
	/* Initialize toolbar items */
    self.statusView = [[[StatusView alloc] initWithFrame:CGRectMake(0,0,225,20)] autorelease];
	
    UIBarButtonItem *statusButton = [[UIBarButtonItem alloc] initWithCustomView:statusView];
    UIBarButtonItem *actionButton = [[UIBarButtonItem alloc]
                                     //initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                     initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                     target:self
                                     action:@selector(selectAction:)];
	UIBarButtonItem *flipButton   = [[UIBarButtonItem alloc]
                                     initWithImage:listIconImage
                                     style:UIBarButtonItemStylePlain
                                     target:self
                                     action:@selector(changeView:)];

	NSArray *items = [NSArray arrayWithObjects:actionButton, statusButton,flipButton,nil];
    [statusButton release];
	[actionButton release];
	[flipButton release];
    [self setToolbarItems:items];
    self.navigationController.toolbar.tintColor = [UIColor colorWithRed:88/255.0 green:136/255.0 blue:181/255.0 alpha:1];
    
    [self.navigationController setToolbarHidden:NO animated:NO];
    self.navigationController.delegate = self;
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:88/255.0 green:136/255.0 blue:181/255.0 alpha:1];
    
    /* Set back button item */
    //UIBarButtonItem *backButton = [[[UIBarButtonItem alloc]
    //                                initWithTitle:@"Browse"
    //                                style:UIBarButtonItemStylePlain
    //                                target:nil
    //                                action:nil] autorelease];
    //self.navigationItem.backBarButtonItem = backButton;
    self.navigationItem.hidesBackButton = YES;
    
    UIImage *brandImage             = [UIImage imageNamed:@"brandname.png"];
    UIImageView *brandImageView     = [[[UIImageView alloc] initWithImage:brandImage] autorelease];
    UIBarButtonItem *brandImageItem = [[[UIBarButtonItem alloc] initWithCustomView:brandImageView] autorelease];
    self.navigationItem.leftBarButtonItem = brandImageItem;
    
    /* Start the show */
    NSDictionary *lastLocationSearched = (NSDictionary*)
        [[NSUserDefaults standardUserDefaults] objectForKey:@"last_location_searched"];
        
    if (lastLocationSearched) {
        NSNumber *lat = [lastLocationSearched objectForKey:@"lat"];
        NSNumber *lng = [lastLocationSearched objectForKey:@"lng"];
            
        [self setOriginAtLat:[lat doubleValue] lng:[lng doubleValue]];
    }
    else {
        [self selectAction:actionButton];
    }
}

/*
-(void) viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
}
*/

/*
-(void) viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/

/*
-(void) viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
}
*/

/*
-(void) viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/

/*
 // Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
 [super viewDidLoad];
 }
 */

/*
 // Override to allow orientations other than the default portrait orientation.
 - (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
 // Return YES for supported orientations
 return (interfaceOrientation == UIInterfaceOrientationPortrait);
 }
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Custom methods
-(void) setOriginAtLat:(float)lat lng:(float)lng {
    [[NSUserDefaults standardUserDefaults]
     setObject:[self makeDictionaryWithLat:lat lng:lng]
     forKey:@"last_location_searched"];
     
    [statusView hideLabel];
    [[self navigationItem] setTitle:@""];
    self.locationPendingSearch = NO;
    
    [self setPage:[NSNumber numberWithInt:0]];
    
    CLLocation *loc = [[[CLLocation alloc] initWithLatitude:lat longitude:lng] autorelease];
    [self setOrigin:loc];
    [mapController setLocation:loc];
    [self.tableController showPage:[NSArray array] withOrigin:loc];
    
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
    [openHouses setOrigin:loc];
    
	[self updateNavButtons];
    [self showPage:[NSNumber numberWithInt:1]];
    
    HistoryManager *history = [HistoryManager sharedHistoryManager];
    [history logLocation:loc];
}

-(void) showPage:(NSNumber *)p {
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
	if ([openHouses hasDataForPage:p] == NO) {
		[self getPage:p];
		return;
	}
    
    //NSString *title = [NSString stringWithFormat:@"Browse (%d)", [[openHouses totalResults] intValue]];
    //[[self navigationItem] setTitle:title];
	
	[[self mapController] showPage:[openHouses getPage:p] withOrigin:origin];
	[[self tableController] showPage:[openHouses getPage:p] withOrigin:origin];
	
	[self setPage:p];
	[self updateNavButtons];
}

-(void) getPage:(NSNumber *)p {
    [statusView showLabel:@"Loading Data..."];
    
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
	[openHouses loadMoreData];
}

-(void) updateNavButtons {
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
	
	[[self navButtons] setEnabled:NO forSegmentAtIndex:0];
	[[self navButtons] setEnabled:NO forSegmentAtIndex:1];
	
	if ([[self page] intValue] < [[openHouses totalPages] intValue]) {
		[[self navButtons] setEnabled:YES forSegmentAtIndex:0];
	}
	if ([[self page] intValue] > 1) {
		[[self navButtons] setEnabled:YES forSegmentAtIndex:1];
	}
}

-(void) selectAction:(id)sender {
    UIActionSheet *menu = [[[UIActionSheet alloc]
                            initWithTitle:@"Search"
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:nil
                            otherButtonTitles:@"Map Center", @"Current Location", @"Address", @"History", nil] autorelease];
    menu.tag = 1;
    menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    id delegate = [[UIApplication sharedApplication] delegate];
    [menu showInView:[delegate window]];
}

-(void) changePage:(id)sender {
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
	
	if ([openHouses.requests count] > 0) {
		return;
	}
	
	NSInteger idx = [sender selectedSegmentIndex];
	
	if (idx == 0) {
		NSNumber *p = [NSNumber numberWithInt:[[self page] intValue] + 1];
		[self showPage:p];
	}
	else if (idx == 1) {
		NSNumber *p = [NSNumber numberWithInt:[[self page] intValue] - 1];
		[self showPage:p];
	}
}

-(void) changeView:(id)sender {
	[self toggleView];
}

-(void) toggleView {
	UIView *mapView   = [mapController view];
	UIView *tableView = [tableController view];
    
	if (activeController == mapController) {
        [[self.toolbarItems objectAtIndex:2] setImage:mapIconImage];
    }
    else {
        [[self.toolbarItems objectAtIndex:2] setImage:listIconImage];
    }
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1.0];
	//[UIView setAnimationTransition:((activeController == mapController) ?
	//								UIViewAnimationTransitionFlipFromRight :
	//								UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	[UIView setAnimationTransition:((activeController == mapController) ?
									UIViewAnimationTransitionCurlUp :
									UIViewAnimationTransitionCurlDown) forView:self.view cache:YES];
	
	if (activeController == mapController) {
		[tableController viewWillAppear:YES];
		[mapController viewWillDisappear:YES];
		[mapView removeFromSuperview];
		[self.view addSubview:tableView];
		[mapController viewDidDisappear:YES];
		[tableController viewDidAppear:YES];
		
		[self setActiveController:tableController];
	}
	else {
		[mapController viewWillAppear:YES];
		[tableController viewWillDisappear:YES];
		[tableView removeFromSuperview];
		[self.view addSubview:mapView];
		[tableController viewDidDisappear:YES];
		[mapController viewDidAppear:YES];
		
		[self setActiveController:mapController];
	}
	
	[UIView commitAnimations];
}

-(void) selectedHouseCallback:(NSNotification *)notification {
	NSObject *object = [notification object];
	
	if([object isKindOfClass:[OpenHouse class]] == YES) {
        OpenHouse *house = (OpenHouse *)object;
        /*
        ImageTableController *detailsController = [[ImageTableController alloc] initWithStyle:UITableViewStyleGrouped];
        [detailsController setHouse:house];
        
		[[self navigationController] pushViewController:detailsController animated:YES];
        return;
        */
        
		DetailsController *detailsController = [[[DetailsController alloc] initWithNibName:nil bundle:nil] autorelease];
        
        [detailsController setHouse:house];
		[[self navigationController] pushViewController:detailsController animated:YES];
	}
}

-(void) selectedLocationCallback:(NSNotification *)notification {
	NSObject *object = [notification object];
	
	if([object isKindOfClass:[NSDictionary class]] == YES) {
        NSDictionary *location = (NSDictionary *)object;
        
        float lat = [[location valueForKey:@"lat"] floatValue];
        float lng = [[location valueForKey:@"lng"] floatValue];
        
        [self setOriginAtLat:lat lng:lng];
	}
}

-(void) selectedAddressCallback:(NSNotification *)notification {
	NSObject *object = [notification object];
	
	if([object isKindOfClass:[NSDictionary class]] == YES) {
        NSDictionary *address = (NSDictionary *)object;

        float lat = [[address valueForKey:@"lat"] floatValue];
        float lng = [[address valueForKey:@"lng"] floatValue];

        [self setOriginAtLat:lat lng:lng];
	}
}

-(NSDictionary *) makeDictionaryWithCLLocation:(CLLocation *)location {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[NSNumber numberWithDouble:location.coordinate.latitude] forKey:@"lat"];
    [dict setObject:[NSNumber numberWithDouble:location.coordinate.longitude] forKey:@"lng"];
    
    return dict;
}

-(NSDictionary *) makeDictionaryWithLat:(double)lat lng:(double)lng {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[NSNumber numberWithDouble:lat] forKey:@"lat"];
    [dict setObject:[NSNumber numberWithDouble:lng] forKey:@"lng"];
    
    return dict;
}

-(void) showAlertWithText:(NSString *)text {
    UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:text
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
    
    [alert show];
    [alert release];
}


#pragma mark -
#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        CLLocationCoordinate2D center = mapController.mapView.centerCoordinate;
        [self setOriginAtLat:center.latitude lng:center.longitude];
    }
    else if (buttonIndex == 1) {
        NSDictionary *lastLocationUpdate = (NSDictionary*)[[NSUserDefaults standardUserDefaults] objectForKey:@"last_location_update"];
        if (lastLocationUpdate) {
            NSNumber *lat = [lastLocationUpdate objectForKey:@"lat"];
            NSNumber *lng = [lastLocationUpdate objectForKey:@"lng"];
            
            [self setOriginAtLat:[lat doubleValue] lng:[lng doubleValue]];
            
            return;
        }
        
        if (self.locationManager == nil) {
            self.locationManager = [[[CLLocationManager alloc] init] autorelease];
            self.locationManager.delegate = self;
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            self.locationManager.distanceFilter = 100;
            [self.locationManager startUpdatingLocation];
        }
        
        [statusView showLabel:@"Locating..."];
        self.locationPendingSearch = YES;
    }
    else if (buttonIndex == 2) {
        AddressController *addressCotroller   = [[[AddressController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:addressCotroller] autorelease];
        
        [navController setToolbarHidden:NO animated:NO];
        navController.navigationBar.tintColor = [UIColor colorWithRed:88/255.0 green:136/255.0 blue:181/255.0 alpha:1];
        navController.toolbar.tintColor = [UIColor colorWithRed:88/255.0 green:136/255.0 blue:181/255.0 alpha:1];
        
        [self.navigationController presentModalViewController:navController animated:YES];
    }
    else if (buttonIndex == 3) {
        HistoryController *historyCotroller   = [[[HistoryController alloc] initWithStyle:UITableViewStylePlain] autorelease];
        UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:historyCotroller] autorelease];

        [navController setToolbarHidden:NO animated:NO];
        navController.navigationBar.tintColor = [UIColor colorWithRed:88/255.0 green:136/255.0 blue:181/255.0 alpha:1];
        navController.toolbar.tintColor = [UIColor colorWithRed:88/255.0 green:136/255.0 blue:181/255.0 alpha:1];

        [self.navigationController presentModalViewController:navController animated:YES];
    }
}


#pragma mark -
#pragma mark UINavigationControllerDelegate methods
-(void) navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController != self) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"browseControllerWillShow" object:nil];
}

-(void) navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (viewController != self) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"browseControllerDidShow" object:nil];
}


#pragma mark -
#pragma mark OpenHousesApiDelegate methods
-(void) finishedWithPage:(NSNumber *)p {
    [statusView hideLabel];
    
    OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
    if ([p intValue] == 1 && [[openHouses totalResults] intValue] < 1) {
        [self.tableController showPage:nil withOrigin:origin];
        
        if (activeController == tableController) {
            return;
        }
        
        NSString *msg = [NSString stringWithFormat:@"No houses found within a %d mile radius.", (int)CONFIG_SEARCH_DISTANCE];
        [self showAlertWithText:msg];
        
        return;
    }
    
	[self showPage:p];
}

-(void) failedWithError:(NSError *)error {
    [statusView hideLabel];
    
    [self showAlertWithText:[error localizedDescription]];
}


#pragma mark -
#pragma mark CLLocationManagerDelegate methods
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {
    NSDictionary *location = [self makeDictionaryWithCLLocation:newLocation];
    [[NSUserDefaults standardUserDefaults] setObject:location forKey:@"last_location_update"];
    [FlurryAPI setLocation:newLocation];
    
    if (self.locationPendingSearch == NO) {
        return;
    }
    
    [statusView hideLabel];
    self.locationPendingSearch = NO;
    [self setOriginAtLat:newLocation.coordinate.latitude lng:newLocation.coordinate.longitude];
}

-(void) locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    if (self.locationPendingSearch == NO) {
        return;
    }
    
    //kCLErrorDenied
    
    self.locationManager = nil;
    [statusView hideLabel];
    self.locationPendingSearch = NO;
    
    NSString *msg = @"Unable to determine your location.";
    [self showAlertWithText:msg];
}
@end


@implementation NSString (Custom)
+(NSString *) encodeURIComponent: (NSString *) url {
    NSArray *escapeChars = [NSArray arrayWithObjects:@";" , @"/" , @"?" , @":" ,
                            @"@" , @"&" , @"=" , @"+" ,
                            @"$" , @"," , @"[" , @"]",
                            @"#", @"!", @"'", @"(", 
                            @")", @"*", @" ", nil];
    
    NSArray *replaceChars = [NSArray arrayWithObjects:@"%3B" , @"%2F" , @"%3F" ,
                             @"%3A" , @"%40" , @"%26" ,
                             @"%3D" , @"%2B" , @"%24" ,
                             @"%2C" , @"%5B" , @"%5D", 
                             @"%23", @"%21", @"%27",
                             @"%28", @"%29", @"%2A",
                             @"%20", nil];
    
    int len = [escapeChars count];
    
    NSMutableString *temp = [url mutableCopy];
    
    int i;
    for(i = 0; i < len; i++)
    {
        
        [temp replaceOccurrencesOfString: [escapeChars objectAtIndex:i]
                              withString:[replaceChars objectAtIndex:i]
                                 options:NSLiteralSearch
                                   range:NSMakeRange(0, [temp length])];
    }
    
    return [temp autorelease];
}

@end


