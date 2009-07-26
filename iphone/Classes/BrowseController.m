//
//  BrowseController.m
//  OpenHouses
//
//  Created by blago on 6/20/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "BrowseController.h"


@interface BrowseController (Private)
-(void) setOriginAtLat:(float)lat lng:(float)lng;
-(void) getPage:(NSNumber *)p;
-(void) showPage:(NSNumber *)p;
-(void) updateNavButtons;
-(void) toggleView;
@end


@implementation BrowseController
@synthesize mapController, tableController, activeController, page, origin, currentAnnotations, navButtons, toolbar, mapIconImage, listIconImage;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self setCurrentAnnotations:[NSArray array]];
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
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedHouseCallback:) name:@"selectedHouse" object:nil];
    }
    return self;
}

-(void) dealloc {
	[mapController release];
	[tableController release];
	[activeController release];
	[page release];
	[origin release];
	[currentAnnotations release];
	[navButtons release];
	[toolbar release];
	[mapIconImage release];
	[listIconImage release];
    
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
	
	/* Initialize the bottom toolbar */
	[self setToolbar:[[[UIToolbar alloc] initWithFrame:CGRectZero] autorelease]];
	[toolbar setBarStyle:UIBarStyleDefault];
	[toolbar sizeToFit];
    CGRect rect = toolbar.frame;
    //rect.origin.y = 436;
    rect.origin.y = 372;
    toolbar.frame = rect;
	[self.view addSubview:toolbar];
 	
	/* Initialize toolbar items */
    int viewWidth      = 225;
    int spinnerWidth   = 20;
    UIView *statusView = [[[UIView alloc] initWithFrame:CGRectMake(0,0,viewWidth,20)] autorelease];
    
    NSString *statusText = @"Loading Data...";
    int labelWidth       = (int) [statusText sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]].width;
    int labelOffset      = (int) (viewWidth - (labelWidth + spinnerWidth + 6)) / 2;
    int spinnerOffset    = labelOffset + labelWidth + 6;
    UILabel *statusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(labelOffset,0,labelWidth,20)] autorelease];
    [statusLabel setBackgroundColor:[UIColor clearColor]];
    [statusLabel setTextColor:[UIColor whiteColor]];
    [statusLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
    //[statusLabel setTextAlignment:UITextAlignmentCenter];
    [statusLabel setText:statusText];
    UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(spinnerOffset,0,spinnerWidth,20)] autorelease];
    [spinner startAnimating];
    [statusView addSubview:spinner];
    [statusView addSubview:statusLabel];
	
    UIBarButtonItem *statusButton  = [[UIBarButtonItem alloc] initWithCustomView:statusView];
    UIBarButtonItem *actionButton  = [[UIBarButtonItem alloc]
                                      initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                      target:self
                                      action:@selector(selectAction:)];
	UIBarButtonItem *flipButton    = [[UIBarButtonItem alloc]
									  initWithImage:listIconImage
									  style:UIBarButtonItemStylePlain
									  target:self
									  action:@selector(changeView:)];

	[toolbar setItems:[NSArray arrayWithObjects:actionButton, statusButton,flipButton,nil]];
    [[[[toolbar items] objectAtIndex:1] view] setAlpha:0.0f];
    [statusButton release];
	[flipButton release];
    
    [self.navigationController setDelegate:self];
    
    [self setOriginAtLat:44.97614 lng:-93.27704];
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
    [self setPage:[NSNumber numberWithInt:0]];
    
    CLLocation *loc = [[[CLLocation alloc] initWithLatitude:lat longitude:lng] autorelease];
    [mapController setLocation:loc];
    [self setOrigin:loc];
    
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
    [openHouses setOrigin:loc];
    
    [self showPage:[NSNumber numberWithInt:1]];
}

-(void) showPage:(NSNumber *)p {
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
	if ([openHouses hasDataForPage:p] == NO) {
		[self getPage:p];
		return;
	}
	
	[[self mapController] showPage:[openHouses getPage:p] withOrigin:origin];
	[[self tableController] showPage:[openHouses getPage:p] withOrigin:origin];
	
	[self setPage:p];
	[self updateNavButtons];
}

-(void) getPage:(NSNumber *)p {
    [[[[toolbar items] objectAtIndex:1] view] setAlpha:1.0f];
    
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
    UIActionSheet *menu = [[UIActionSheet alloc]
                           initWithTitle:@"New browse localion from"
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:nil
                           otherButtonTitles:@"Current Location", @"Map Center", @"Browse History", @"Address", nil];
    menu.tag = 1;
    menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    id delegate = [[UIApplication sharedApplication] delegate];
    [menu showInView:[delegate window]];
}

-(void) changePage:(id)sender {
	OpenHouses *openHouses = [OpenHouses sharedOpenHouses];
	
	if ([openHouses pendingRequest] == YES) {
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
        [[[toolbar items] objectAtIndex:2] setImage:mapIconImage];
    }
    else {
        [[[toolbar items] objectAtIndex:2] setImage:listIconImage];
    }
	
	[UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
	[UIView setAnimationTransition:((activeController == mapController) ?
									UIViewAnimationTransitionFlipFromRight :
									UIViewAnimationTransitionFlipFromLeft) forView:self.view cache:YES];
	
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
    [self.view bringSubviewToFront:toolbar];
}

-(void) selectedHouseCallback:(NSNotification *)notification {
	NSObject *object = [notification object];
	
	if([object isKindOfClass:[OpenHouse class]] == YES) {
        OpenHouse *house = (OpenHouse *)object;
		DetailsController *detailsController = [[[DetailsController alloc] initWithNibName:nil bundle:nil] autorelease];
        
        [detailsController setHouse:house];
		[[self navigationController] pushViewController:detailsController animated:YES];
	}
}


#pragma mark ---- UIActionSheetDelegate methods ----
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
    }
    else if (buttonIndex == 1) {
        CLLocationCoordinate2D center = mapController.mapView.centerCoordinate;
        [self setOriginAtLat:center.latitude lng:center.longitude];
    }
    else if (buttonIndex == 2) {
    }
    else if (buttonIndex == 3) {
    }
    
    NSLog(@"%d", buttonIndex);
}


#pragma mark ---- UINavigationControllerDelegate methods ----
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


#pragma mark ---- OpenHousesApiDelegate methods ----
-(void) finishedWithPage:(NSNumber *)p {
    [[[[toolbar items] objectAtIndex:1] view] setAlpha:0.0f];
    
	[self showPage:p];
}

-(void) failedWithError:(NSError *)error {
    [[[[toolbar items] objectAtIndex:1] view] setAlpha:0.0f];
    
	UIAlertView *alert = [[UIAlertView alloc]
                          initWithTitle:nil
                          message:@"An API error has ocurred. Please try again later."
                          delegate:self
                          cancelButtonTitle:nil
                          otherButtonTitles:@"OK", nil];
	
    [alert show];
    [alert release];
}

@end
