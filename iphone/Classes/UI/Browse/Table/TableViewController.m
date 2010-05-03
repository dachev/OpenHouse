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
@end

@interface TableViewController (Private)
-(void) cancelRequests;
@end

@implementation TableViewController
@synthesize currentAnnotations, thumbnails, requests, noResults;

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
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    
	for (id key in requests) {
        NSURLRequest *request = [requests objectForKey:key];
		[manager cancelRequest:request];
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
		
		NSString *thumbLink  = [NSString encodeURIComponent:[[house imageLinks] objectAtIndex:0]];
		NSString *url        = [NSString stringWithFormat:IMAGE_API_REQUEST_URL, @"t", thumbLink];
		NSString *identifier = [NSString stringWithFormat:@"%d", idx];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
		[request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
		//[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
        [requests setObject:request forKey:identifier];
        
        ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
        [manager
         addRequest:request
         withTag:identifier
         delegate:self
         didFinishSelector:@selector(getThumbFinishWithData:)
         didFailSelector:@selector(getThumbFailWithData:)
         ];
	}
}

-(void) showPage:(NSArray *)annotations withOrigin:(CLLocation *)origin {
	[self cancelRequests];
    [self setRequests:[NSMutableDictionary dictionary]];
    [self.tableView setContentOffset:CGPointMake(0,0)];
    
    if (annotations == nil) {
        self.noResults = YES;
        [self setCurrentAnnotations:[NSArray array]];
    }
    else {
        self.noResults = NO;
        [self setCurrentAnnotations:annotations];
    }
    
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
    if (self.noResults == YES) {
        return 3;
    }
    
    return [currentAnnotations count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.noResults == YES) {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"noResultsCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noResultsCell"] autorelease];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if (indexPath.row != 2) {
            return cell;
        }
        
        UILabel *label = [[[UILabel alloc] initWithFrame:CGRectMake(0,12,320,20)] autorelease];
        label.text = @"No Results";
            
        label.textAlignment = UITextAlignmentCenter;
        label.textColor = [UIColor lightGrayColor];
        [cell.contentView addSubview:label];
            
        return cell;
    }
    
	OpenHouse *house = [currentAnnotations objectAtIndex:indexPath.row];
    HouseTableCell *cell = (HouseTableCell *)[tableView dequeueReusableCellWithIdentifier:@"HouseCell"];
    if (cell == nil) {
        cell = [[[HouseTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HouseCell"] autorelease];
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
    if (self.noResults == YES) {
        return;
    }
    
	OpenHouse *house = [currentAnnotations objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedHouse" object:house];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.noResults == YES) {
        return;
    }
    
	OpenHouse *house = [currentAnnotations objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedHouse" object:house];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.noResults == YES) {
        return 45.0f;
    }
    
	return 60.0f;
}


#pragma mark -
#pragma mark Image API delegates
-(void) getThumbFinishWithData:(NSDictionary *)data {
    NSUInteger code         = [(NSHTTPURLResponse *)[data objectForKey:@"response"] statusCode];
    NSData *payload         = [data objectForKey:@"data"];
    NSString *tag           = [data objectForKey:@"tag"];
    
    [requests removeObjectForKey:tag];
    
    if(code != 200) {
        return;
    }
    
	NSUInteger idx         = (NSUInteger) [tag intValue];
	NSUInteger indexes[]   = {0,idx};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	UITableViewCell *cell  = [[self tableView] cellForRowAtIndexPath:indexPath];
	UIImage *thumb         = [UIImage imageWithData:payload];
    
    if (thumb == nil) {
        return;
    }
    
	[thumbnails replaceObjectAtIndex:idx withObject:thumb];
	cell.imageView.image = thumb;
}

-(void) getThumbFailWithData:(NSDictionary *)data {
    NSString *tag  = [data objectForKey:@"tag"];
    
    [requests removeObjectForKey:tag];
    
    //NSError *error = [data objectForKey:@"error"];
	//NSLog(@"%@:%@", tag, [error localizedDescription]);
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"thumbRequestFailed" object:error];
}

@end

