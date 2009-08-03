//
//  HistoryController.m
//  OpenHouses
//
//  Created by blago on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HistoryController.h"


@implementation HistoryController
@synthesize sortButtons;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.navigationItem.prompt = @"Select a location";
        
        // Set bottom buttons
		NSArray *sortItems = [NSArray arrayWithObjects:@"Last Updated", @"Most Frequent", nil];
		[self setSortButtons:[[[UISegmentedControl alloc] initWithItems:sortItems] autorelease]];
        
		[sortButtons addTarget:self action:@selector(changeOrder:) forControlEvents:UIControlEventValueChanged];
		[sortButtons setSegmentedControlStyle:UISegmentedControlStyleBar];
        
		UIBarButtonItem *barSortButton      = [[[UIBarButtonItem alloc] initWithCustomView:sortButtons] autorelease];
        UIBarButtonItem *flexibleSpaceLeft  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *flexibleSpaceRight = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        [self setToolbarItems:[NSArray arrayWithObjects:flexibleSpaceLeft, barSortButton, flexibleSpaceRight, nil] animated:NO];
        
        
        // Set top buttons
		UIBarButtonItem *barCancelButton = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Cancel"
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(cencelHandler:)];
		UIBarButtonItem *barClearButton  = [[UIBarButtonItem alloc]
                                            initWithTitle:@"Clear"
                                            style:UIBarButtonItemStyleBordered
                                            target:self
                                            action:@selector(clearHandler:)];
        
		[[self navigationItem] setRightBarButtonItem:barCancelButton];
		[[self navigationItem] setLeftBarButtonItem:barClearButton];
        
        int sortIdx = 0;
        NSNumber *sortMethod = [[NSUserDefaults standardUserDefaults] objectForKey:@"sort_location_history_idx"];
        if (sortMethod != nil) {
            sortIdx = [sortMethod intValue];
        }
        
        [sortButtons setSelectedSegmentIndex:sortIdx];
        [self sortWithIndex:sortIdx];
    }
    
    return self;
}

-(void) dealloc {
    [sortButtons release];
    
    [super dealloc];
}


#pragma mark -
#pragma mark Standard UIViewController stuff
/*
- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
*/

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
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
-(void) changeOrder:(id)sender {
	NSInteger idx = [sender selectedSegmentIndex];
    
	if (idx == 0) {
        [self sortWithIndex:0];
	}
	else if (idx == 1) {
        [self sortWithIndex:1];
	}
}

-(void) sortWithIndex:(int)idx {
    if (idx == 0) {
        self.navigationItem.title = @"Last Updated";
    }
    else if (idx == 1) {
        self.navigationItem.title = @"Most Frequent";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:idx] forKey:@"sort_location_history_idx"];
    [self.tableView reloadData];
}

-(void) cencelHandler:(int)idx {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) clearHandler:(int)idx {
    UIActionSheet *menu = [[UIActionSheet alloc]
                           initWithTitle:nil
                           delegate:self
                           cancelButtonTitle:@"Cancel"
                           destructiveButtonTitle:@"Clear Locaion History"
                           otherButtonTitles:nil];
    menu.tag = 1;
    menu.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    id delegate = [[UIApplication sharedApplication] delegate];
    [menu showInView:[delegate window]];
}


#pragma mark -
#pragma mark UITableViewDataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

// Customize the appearance of table view cells.
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
	
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController];
	// [anotherViewController release];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
 */


#pragma mark ---- UIActionSheetDelegate methods ----
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        Database *db = [Database sharedDatabase];
        [db deleteAllLocations];
        [self.tableView reloadData];
    }
}



@end

