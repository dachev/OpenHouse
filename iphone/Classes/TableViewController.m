//
//  TableViewController.m
//  OpenHouses
//
//  Created by blago on 6/21/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "TableViewController.h"

@interface NSString (Custom)
+(NSString *) encodeURIComponent: (NSString *) url;
-(void) cancelRequests;
@end

@interface TableViewController (Private)
-(void) cancelRequests;
@end

@implementation TableViewController
@synthesize currentAnnotations, thumbnails, requests;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		[self setCurrentAnnotations:[NSArray array]];
		[self setRequests:[NSMutableDictionary dictionary]];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseControllerCallback) name:@"browseControllerWillShow" object:nil];
    }
	
    return self;
}

-(void) dealloc {
	[self cancelRequests];
    
	[currentAnnotations release];
	[thumbnails release];
    [requests release];
	
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
#pragma mark Custom methods
-(void) cancelRequests {
	for (id key in requests) {
        TaggedRequest *request = [requests objectForKey:key];
        [request delegate:nil didFinishSelector:nil didFailSelector:nil];
    }
}

-(void) setCurrentAnnotations:(NSArray *)v {
	[v retain];
	[currentAnnotations release];
	currentAnnotations = v;
	
    [self setThumbnails:[NSMutableArray arrayWithCapacity:RESULTS_PER_PAGE_DISPLAY]];
    
	int idx = -1;
	UIImage *defaultImage = [UIImage imageNamed:@"loading.png"];
	for (OpenHouse *house in currentAnnotations) {
		[thumbnails addObject: defaultImage];
		idx++;
		
		if ([[house imageLinks] count] < 1) {
			continue;
		}
		
		NSString *thumbLink = [NSString encodeURIComponent:[[house imageLinks] objectAtIndex:0]];
		NSString *url       = [NSString stringWithFormat:IMAGE_API_REQUEST_URL, @"t", thumbLink];
		
		NSString *identifier = [NSString stringWithFormat:@"%d", idx];
		TaggedRequest *request = [TaggedRequest requestWithId:identifier url:url];
		[request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
		//[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
		[request delegate:self didFinishSelector:@selector(getThumbFinish:withData:) didFailSelector:@selector(getThumbFail:withError:)];
        [requests setObject:request forKey:identifier];
		
		ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
		[manager add:request];
	}
}

-(void) showPage:(NSArray *)annotations withOrigin:(CLLocation *)origin {
	[self cancelRequests];
    [self setRequests:[NSMutableDictionary dictionary]];
	[self setCurrentAnnotations:annotations];
    [self.tableView setContentOffset:CGPointMake(0,0)];
	[self.tableView reloadData];
}

-(void) browseControllerCallback {
    NSIndexPath *tableSelection = [self.tableView indexPathForSelectedRow];
    [self.tableView deselectRowAtIndexPath:tableSelection animated:YES];
}


#pragma mark -
#pragma mark UITableViewDataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// Customize the number of rows in the table view.
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [currentAnnotations count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	OpenHouse *house = [currentAnnotations objectAtIndex:indexPath.row];
    
    HouseTableCell *cell = (HouseTableCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[[HouseTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
		//cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
		//cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
	UIImage *thumb = [thumbnails objectAtIndex:indexPath.row];
	[cell setHouse:house withThumb:(UIImage *)thumb];
	
	//[self.tableView scrollRectToVisible:animated:NO];
	
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods
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


#pragma mark -
#pragma mark Image API delegates
-(void) getThumbFinish:(TaggedURLConnection *)connection withData:(NSData *)data {
    // remove request from container
    [requests removeObjectForKey:[connection tag]];
    
    if([connection status] != 200) {
        return;
    }
    
	NSUInteger idx = (NSUInteger) [[connection tag] intValue];
	NSUInteger indexes[] = {0,idx};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	UITableViewCell *cell = [[self tableView] cellForRowAtIndexPath:indexPath];
	
	UIImage *thumb = [UIImage imageWithData:data];
    
    if (thumb == nil) {
        return;
    }
    
	[thumbnails replaceObjectAtIndex:idx withObject:thumb];
	cell.imageView.image = thumb;
}

-(void) getThumbFail:(TaggedURLConnection *)connection withError:(NSString *)error {
    // remove request from container
    [requests removeObjectForKey:[connection tag]];
    
	//NSLog(@"%@:%@", [connection tag], error);
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"thumbRequestFailed" object:error];
}

@end

