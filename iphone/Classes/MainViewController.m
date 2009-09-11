//
//  MainViewController.m
//  OpenHouses
//
//  Created by blago on 6/9/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "MainViewController.h"


@implementation MainViewController
@synthesize browseController;


-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self setBrowseController:[[[BrowseController alloc] initWithNibName:nil bundle:nil] autorelease]];
		[self pushViewController:browseController animated:NO];
    }
    return self;
}

-(void) dealloc {
	[browseController release];
	
    [super dealloc];
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

-(void) viewDidLoad {
    [super viewDidLoad];
	
	[self.view setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];
	//[self.view setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
}

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



@end
