//
//  TableViewController.m
//  OpenHouses
//
//  Created by blago on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"


@implementation TableViewController
@synthesize currentAnnotations, thumbnails;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		[self setCurrentAnnotations:[NSArray array]];
		[self setThumbnails:[NSMutableArray arrayWithCapacity:RESULTS_PER_PAGE_DISPLAY]];
    }
	
    return self;
}

-(void) dealloc {
	[currentAnnotations release];
	[thumbnails release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Standard UIViewController stuff
-(void) viewDidLoad {
    [super viewDidLoad];
 
 
	[self.view setFrame:CGRectMake(0,0,320,372)];
}

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
#pragma mark Custom UITableViewController methods
-(void) setCurrentAnnotations:(NSArray *)v {
	[v retain];
	[currentAnnotations release];
	currentAnnotations = v;
	
	int idx = -1;
	UIImage *defaultImage = [UIImage imageNamed:@"loading.png"];
	for (OpenHouse *house in currentAnnotations) {
		[thumbnails addObject: defaultImage];
		idx++;
		
		if ([[house imageLinks] count] < 1) {
			continue;
		}
		
		NSString *thumbLink = [[[house imageLinks] objectAtIndex:0] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		NSString *url       = [NSString stringWithFormat:IMAGE_API_REQUEST_URL, @"t", thumbLink];
		
		NSString *identifier = [NSString stringWithFormat:@"%d", idx];
		TaggedRequest *request = [TaggedRequest requestWithId:identifier url:url];
		[request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
		//[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
		[request delegate:self didFinishSelector:@selector(getThumbFinish:withData:) didFailSelector:@selector(getThumbFail:withError:)];
		
		ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
		[manager add:request];
	}
}

-(void) showPage:(NSArray *)annotations withOrigin:(CLLocation *)origin {
	[self setCurrentAnnotations:annotations];
    [self.tableView setContentOffset:CGPointMake(0,0)];
	[self.tableView reloadData];
}


#pragma mark -
#pragma mark Table view data source methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentAnnotations count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	OpenHouse *house = [currentAnnotations objectAtIndex:indexPath.row];
    
    HouseTableCell *cell = (HouseTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[HouseTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
		cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	UIImage *thumb = [thumbnails objectAtIndex:indexPath.row];
	[cell setHouse:house withThumb:(UIImage *)thumb];
	
	//[self.tableView scrollRectToVisible:animated:NO];
	
    return cell;
}


#pragma mark -
#pragma mark Table view methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	OpenHouse *house = [currentAnnotations objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedHouse" object:house];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	OpenHouse *house = [currentAnnotations objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedHouse" object:house];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	//return 93.0f;
	return 60.0f;
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


#pragma mark -
#pragma mark Image API delegates
-(void) getThumbFinish:(TaggedURLConnection *)connection withData:(NSData *)data {
    if([connection status] != 200) {
        return;
    }
    
	NSUInteger idx = (NSUInteger) [[connection tag] intValue];
	NSUInteger indexes[] = {0,idx};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
	
	UIImage *thumb = [UIImage imageWithData:data];
	[thumbnails replaceObjectAtIndex:idx withObject:thumb];
	cell.imageView.image = thumb;
}

-(void) getThumbFail:(TaggedURLConnection *)connection withError:(NSString *)error {
	//NSLog(@"%@:%@", [connection tag], error);
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"thumbRequestFailed" object:error];
}


@end

