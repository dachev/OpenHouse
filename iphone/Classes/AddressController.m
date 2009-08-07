//
//  AddressController.m
//  OpenHouses
//
//  Created by blago on 8/3/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AddressController.h"

@interface NSString (Custom)
+(NSString *) encodeURIComponent: (NSString *) url;
@end

@interface AddressController (Private)
-(void) getAddressesFinish:(TaggedURLConnection *)connection withData:(NSData *)data;
-(void) getAddressesFail:(TaggedURLConnection *)connection withError:(NSString *)error;
-(void) showAlertWithText:(NSString *)text;
@end

@implementation AddressController
@synthesize statusView, searchBar, addresses;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self setAddresses:[NSArray array]];
        
        NSString *query = [[NSUserDefaults standardUserDefaults] objectForKey:@"address_search_query"];
        if (query == nil) {
            query = @"";
        }
        
        [self setSearchBar:[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,320,45)]];
        self.navigationItem.titleView = searchBar;
        [searchBar becomeFirstResponder];
        searchBar.text        = query;
        searchBar.delegate    = self;
        searchBar.placeholder = @"US address, city, or zip";
        
        // Set bottom buttons
        
        StatusView *sv                   = [[[StatusView alloc] initWithFrame:CGRectMake(0,0,225,20)] autorelease];
        StatusView *statusButton         = [[UIBarButtonItem alloc] initWithCustomView:sv];
        UIBarButtonItem *flexibleSpace1  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *flexibleSpace3  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
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

        self.toolbarItems = [NSArray arrayWithObjects:barClearButton, flexibleSpace1, statusButton, flexibleSpace3, barCancelButton, nil];
        
        [self setStatusView:sv];
    }
    
    return self;
}

-(void) dealloc {
    [statusView release];
    [searchBar release];
    [addresses release];
    
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
-(void) cencelHandler:(int)idx {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) clearHandler:(int)idx {
    [self setAddresses:[NSArray array]];
    [searchBar setText:@""];
    [self.tableView reloadData];
}

-(float) calculateHeightFromWidth:(float)width text:(NSString *)text font:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode {
    [text retain];
    [font retain];
    
    CGSize suggestedSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
    
    [text release];
    [font release];
    
    return suggestedSize.height;
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
#pragma mark UITableViewDataSource methods
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [addresses count];
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"cellID"] autorelease];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont systemFontSize]-1];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        
        cell.textLabel.textColor = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    NSDictionary *address = [addresses objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [address valueForKey:@"address"];
    cell.textLabel.text = [cell.detailTextLabel.text isEqualToString:@""] ? @"" : @"Location:";
    
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.lineBreakMode = UILineBreakModeWordWrap;
    cell.detailTextLabel.backgroundColor = [UIColor blackColor];
    cell.textLabel.backgroundColor = [UIColor blackColor];
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedAddressFromGeocoding" object:[addresses objectAtIndex:indexPath.row]];
    
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *address = [addresses objectAtIndex:indexPath.row];
    NSString *text        = [address valueForKey:@"address"];
    UIFont *font          = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    UILineBreakMode bMode = UILineBreakModeWordWrap;
    
    CGFloat height    = [self calculateHeightFromWidth:227.0f text:text font:font lineBreakMode:bMode] + 25;
    if (height < 45.0f) {
        height = 45.0f;
    }
    
    return height;
}


#pragma mark -
#pragma mark UISearchBarDelegate methods
-(void) searchBarSearchButtonClicked:(UISearchBar *)sBar {
    [self setAddresses:[NSArray array]];
    
    NSString *query      = [searchBar text];
    NSString *url        = [NSString stringWithFormat:GOOGLE_GEOCODING_URL, [NSString encodeURIComponent:query]];
    NSString *identifier = [NSString stringWithFormat:@"%d", [[NSDate date] timeIntervalSince1970]];
    
    TaggedRequest *request = [TaggedRequest requestWithId:identifier url:url];
    [request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
    [request delegate:self didFinishSelector:@selector(getAddressesFinish:withData:) didFailSelector:@selector(getAddressesFail:withError:)];
    
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    [manager add:request];
    
    [searchBar resignFirstResponder];
    
    [[NSUserDefaults standardUserDefaults] setObject:query forKey:@"address_search_query"];
    [statusView showLabel:@"Searching..."];
}

-(void) searchBar:(UISearchBar *)sBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        [self setAddresses:[NSArray array]];
        [self.tableView reloadData];
    }
}


#pragma mark -
#pragma mark Geocoding API delegates
-(void) getAddressesFinish:(TaggedURLConnection *)connection withData:(NSData *)data {
    [statusView hideLabel];
    
    if([connection status] != 200) {
        [self showAlertWithText:@"google geocoding API error"];
        return;
    }
    
	NSDictionary *response = [[CJSONDeserializer deserializer] deserializeAsDictionary:data error:nil];
	if (response == nil) {
        [self showAlertWithText:@"no results found"];
        return;
	}
    
    NSDictionary *status = [response objectForKey:@"Status"];
	if (status == nil || [[status objectForKey:@"code"] intValue] != 200) {
        [self showAlertWithText:@"no results found"];
        return;
	}
    
    NSUInteger counter    = 0;
    NSMutableArray *items = [NSMutableArray array];
    NSArray *placemarks   = [response objectForKey:@"Placemark"];
    
    if (placemarks == nil || [placemarks count] < 1) {
        [self showAlertWithText:@"no results found"];
        return;
    }
    
    for (NSDictionary *placemark in placemarks) {
        NSString *address     = [placemark valueForKey:@"address"];
        NSDictionary *point   = [placemark valueForKey:@"Point"];
        NSDictionary *details = [placemark valueForKey:@"AddressDetails"];
        
        if (address == nil || point == nil || details == nil) {
            continue;
        }
        
        NSArray *coordinates = [point valueForKey:@"coordinates"];
        if ([coordinates count] != 3) {
            continue;
        }
        float lat = [[coordinates objectAtIndex:1] floatValue];
        float lng = [[coordinates objectAtIndex:0] floatValue];
        
        NSDictionary *country = [details valueForKey:@"Country"];
        if (country == nil) {
            continue;
        }
        
        NSString *ccode = [country valueForKey:@"CountryNameCode"];
        if (ccode == nil || ![ccode isEqualToString:@"US"]) {
            continue;
        }
        
        NSDictionary *item = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:lat], @"lat",
                              [NSNumber numberWithFloat:lng], @"lng",
                              address, @"address",
                              nil];
        [items addObject:item];
        counter++;
    }
    
    [self setAddresses:items];
    [self.tableView reloadData];
    
    if ([items count] > 0) {
        return;
    }
    
    [self showAlertWithText:@"no results found"];
}

-(void) getAddressesFail:(TaggedURLConnection *)connection withError:(NSString *)error {
    [self showAlertWithText:error];
    
    [statusView hideLabel];
    [self setAddresses:[NSArray array]];
}




@end

