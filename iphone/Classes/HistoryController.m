//
//  HistoryController.m
//  OpenHouses
//
//  Created by blago on 8/2/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "HistoryController.h"


@implementation HistoryController
@synthesize locations, sortButtons, sortIdx;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        self.navigationItem.prompt = @"Select a location";
        
        // Set bottom buttons
		NSArray *sortItems = [NSArray arrayWithObjects:@"Latest", @"Most Frequent", nil];
		[self setSortButtons:[[[UISegmentedControl alloc] initWithItems:sortItems] autorelease]];
        
		[sortButtons addTarget:self action:@selector(changeOrder:) forControlEvents:UIControlEventValueChanged];
		[sortButtons setSegmentedControlStyle:UISegmentedControlStyleBar];
        
		UIBarButtonItem *barSortButton      = [[[UIBarButtonItem alloc] initWithCustomView:sortButtons] autorelease];
        UIBarButtonItem *flexibleSpaceLeft  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *flexibleSpaceRight = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        [self setToolbarItems:[NSArray arrayWithObjects:flexibleSpaceLeft, barSortButton, flexibleSpaceRight, nil] animated:NO];
        
        
        // Set top buttons
		UIBarButtonItem *barCancelButton = [[[UIBarButtonItem alloc]
                                             initWithTitle:@"Cancel"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(cencelHandler:)] autorelease];
		UIBarButtonItem *barClearButton  = [[[UIBarButtonItem alloc]
                                             initWithTitle:@"Clear"
                                             style:UIBarButtonItemStyleBordered
                                             target:self
                                             action:@selector(clearHandler:)] autorelease];
        
		[[self navigationItem] setRightBarButtonItem:barCancelButton];
		[[self navigationItem] setLeftBarButtonItem:barClearButton];
        
        [self setLocations:[NSArray array]];
        
        [self setSortIdx:0];
        NSNumber *sortMethod = [[NSUserDefaults standardUserDefaults] objectForKey:@"sort_location_history_idx"];
        if (sortMethod != nil) {
            [self setSortIdx:[sortMethod intValue]];
        }
        
        [sortButtons setSelectedSegmentIndex:sortIdx];
        [self sort];
    }
    
    return self;
}

-(void) dealloc {
    [locations release];
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
        [self setSortIdx:0];
	}
	else if (idx == 1) {
        [self setSortIdx:1];
	}
    
    [self sort];
}

-(void) sort {
    Database *db = [Database sharedDatabase];
    
    if (sortIdx == 0) {
        [self setLocations:[db getLocationsSortedBy:@"updated_on"]];
        self.navigationItem.title = @"Latest";
    }
    else if (sortIdx == 1) {
        [self setLocations:[db getLocationsSortedBy:@"count"]];
        self.navigationItem.title = @"Most Frequent";
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:sortIdx] forKey:@"sort_location_history_idx"];
    [self.tableView reloadData];
}

-(void) cencelHandler:(int)idx {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) clearHandler:(int)idx {
    UIActionSheet *menu = [[[UIActionSheet alloc]
                            initWithTitle:nil
                            delegate:self
                            cancelButtonTitle:@"Cancel"
                            destructiveButtonTitle:@"Clear Locaion History"
                            otherButtonTitles:nil] autorelease];
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
    return [locations count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSDictionary *location = [locations objectAtIndex:indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
        
        [cell.textLabel setFont:[UIFont fontWithName:@"HelveticaNeue-Bold" size:15]];
        [cell.detailTextLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:13]];
    }

    NSDateFormatter *formatter = [[[NSDateFormatter alloc] init] autorelease];
    [formatter setDateFormat:LOCATION_HISTORY_DATETIME];
    NSString *updatedText = [formatter stringFromDate:[location valueForKey:@"updated_on"]];
    
    NSString *addressText = [location valueForKey:@"address"];
    if ([addressText isEqualToString:@""]) {
        NSString *lat = [location valueForKey:@"lat"];
        NSString *lng = [location valueForKey:@"lng"];
        addressText = [NSString stringWithFormat:@"%@, %@", lat, lng];
    }
    
	[cell.textLabel setText:addressText];
    [cell.detailTextLabel setText:updatedText];
	
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedLocationFromHistory" object:[locations objectAtIndex:indexPath.row]];
    [self.navigationController dismissModalViewControllerAnimated:YES];
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

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 50.0f;
}


#pragma mark -
#pragma mark UIActionSheetDelegate methods
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 0) {
        Database *db = [Database sharedDatabase];
        [db deleteAllLocations];
        [self sort];
    }
}



@end

