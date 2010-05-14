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
@synthesize annotations, timers, requests, thumbnails, noResults;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
		self.annotations = [NSArray array];
        self.timers      = [NSMutableArray array];
		self.requests    = [NSMutableDictionary dictionary];
        self.thumbnails  = [NSMutableArray array];
        
        //self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
        
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(browseControllerCallback) name:@"browseControllerWillShow" object:nil];
    }
	
    return self;
}

-(void) dealloc {
	[self cancelRequests];
    
	[annotations release];
    [timers release];
    [requests release];
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
#pragma mark Custom methods
-(void) cancelRequests {
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    
	for (id key in requests) {
        NSURLRequest *request = [requests objectForKey:key];
		[manager cancelRequest:request];
    }
}

-(void) requestImage:(NSTimer*)theTime {
    NSNumber *info        = (NSNumber*)[theTime userInfo];
    OpenHouse *house      = [annotations objectAtIndex:[info intValue]];
    NSString *link        = [[house imageLinks] objectAtIndex:0];
    NSString *encodedLink = [NSString encodeURIComponent:link];
    NSString *url         = [NSString stringWithFormat:IMAGE_API_REQUEST_URL, @"t", encodedLink];
    NSString *identifier  = [info stringValue];
    NSLog(@"%d:%@", [info intValue], link);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
    //[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [requests setObject:request forKey:identifier];
        
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    [manager addRequest:request
                withTag:identifier
               delegate:self
      didFinishSelector:@selector(getThumbFinishWithData:)
        didFailSelector:@selector(getThumbFailWithData:)
             checkCache:YES
            saveToCache:YES
        ];
}

-(void) setAnnotations:(NSArray *)v {
	[v retain];
	[annotations release];
	annotations = v;
	
    self.thumbnails = [NSMutableArray arrayWithCapacity:RESULTS_PER_PAGE_DISPLAY];
    
	for (int idx = 0; idx < [self.timers count]; idx++) {
        NSTimer *timer = [timers objectAtIndex:idx];
        if ([timer isValid]) {
            [timer invalidate];
        }
    }
    self.timers = [NSMutableArray array];
    
	UIImage *defaultImage = [UIImage imageNamed:@"loading.png"];
	for (int idx = 0; idx < [self.annotations count]; idx++) {
		[self.thumbnails addObject: defaultImage];
        
        OpenHouse *house = [self.annotations objectAtIndex:idx];
		if ([[house imageLinks] count] < 1) {
			continue;
		}
        
        NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:0.02
                                         target:self
                                       selector:@selector(requestImage:)
                                       userInfo:[NSNumber numberWithInt:idx]
                                        repeats:NO];
        [self.timers addObject:timer];
	}
}

-(void) showPage:(NSArray *)a withOrigin:(CLLocation *)origin {
	[self cancelRequests];
    [self setRequests:[NSMutableDictionary dictionary]];
    [self.tableView setContentOffset:CGPointMake(0,0)];
    
    if (a == nil) {
        self.noResults = YES;
        [self setAnnotations:[NSArray array]];
    }
    else {
        self.noResults = NO;
        [self setAnnotations:a];
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
    
    return [annotations count];
}

// Customize the appearance of table view cells.
-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.noResults == YES) {
        UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"noResultsCell"];
        if (cell == nil) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"noResultsCell"] autorelease];
            cell.selectionStyle  = UITableViewCellSelectionStyleNone;
            //cell.backgroundColor = [UIColor whiteColor];
        }
        
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
    
	OpenHouse *house = [annotations objectAtIndex:indexPath.row];
    HouseTableCell *cell = (HouseTableCell *)[tableView dequeueReusableCellWithIdentifier:@"HouseCell"];
    if (cell == nil) {
        cell = [[[HouseTableCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"HouseCell"] autorelease];
		//cell.accessoryType  = UITableViewCellAccessoryDetailDisclosureButton;
        cell.accessoryType  = UITableViewCellAccessoryDisclosureIndicator;
        //cell.backgroundColor = [UIColor whiteColor];
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
    
	OpenHouse *house = [annotations objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedHouse" object:house];
}

-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (self.noResults == YES) {
        return;
    }
    
	OpenHouse *house = [annotations objectAtIndex:indexPath.row];
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
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)[data objectForKey:@"response"];
    NSData *payload         = [data objectForKey:@"data"];
    NSString *tag           = [data objectForKey:@"tag"];
    
    [requests removeObjectForKey:tag];
    
    if(resp && [resp statusCode] != 200) {
        return;
    }
    
	NSUInteger idx = (NSUInteger) [tag intValue];
    if (idx >= [annotations count]) {
        return;
    }
    
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

