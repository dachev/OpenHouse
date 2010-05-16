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

@interface UITableViewCell (Custom)
+(float) calculateHeightFromWidth:(float)width text:(NSString *)text font:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode;
@end

@interface AddressController (Private)
-(void) cancelRequests;
-(void) showAlertWithText:(NSString *)text;
@end

@implementation AddressController
@synthesize statusView, searchBar, addresses, requests, noResults;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithStyle:(UITableViewStyle)style {
    if (self = [super initWithStyle:style]) {
        [self setRequests:[NSMutableDictionary dictionary]];
        [self setAddresses:[NSArray array]];
        
        NSString *query = [[NSUserDefaults standardUserDefaults] objectForKey:@"address_search_query"];
        if (query == nil) {
            query = @"";
        }
        
        float width = self.view.bounds.size.width;
        [self setSearchBar:[[[UISearchBar alloc] initWithFrame:CGRectMake(0,0,width,44)] autorelease]];
        self.navigationItem.titleView = searchBar;
        
        [searchBar becomeFirstResponder];
        
        searchBar.tintColor         = [UIColor colorWithRed:88/255.0 green:136/255.0 blue:181/255.0 alpha:1];
        searchBar.delegate          = self;
        searchBar.text              = query;
        searchBar.delegate          = self;
        searchBar.placeholder       = @"US address, city, or zip";
        searchBar.showsCancelButton = YES;
        
        // Set bottom buttons
        StatusView *sv                   = [[[StatusView alloc] initWithFrame:CGRectMake(0,0,225,20)] autorelease];
        StatusView *statusButton         = [[[UIBarButtonItem alloc] initWithCustomView:sv] autorelease];
        UIBarButtonItem *flexibleSpace1  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        UIBarButtonItem *flexibleSpace3  = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease];
        self.toolbarItems = [NSArray arrayWithObjects:flexibleSpace1, statusButton, flexibleSpace3, nil];
        
        [self setStatusView:sv];
    }
    
    return self;
}

-(void) dealloc {
    [self cancelRequests];
    
    [statusView release];
    [searchBar release];
    [addresses release];
    [requests release];
    
    [super dealloc];
}

-(void) cancelRequests {
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    
    for (id key in requests) {
        NSURLRequest *request = [requests objectForKey:key];
        [manager cancelRequest:request];
    }
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
-(void) clearHandler:(int)idx {
    [self setAddresses:[NSArray array]];
    [searchBar setText:@""];
    [self.tableView reloadData];
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
    if (self.noResults == YES) {
        return 3;
    }

    return [addresses count];
}

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

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addressCell"];
    if (cell == nil) {
        cell = [[[AddressResultCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"addressCell"] autorelease];
        
        //cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.textLabel.font       = [UIFont systemFontOfSize:[UIFont systemFontSize]-1];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        
        cell.textLabel.textColor       = [UIColor grayColor];
        cell.detailTextLabel.textColor = [UIColor blackColor];
    }
    
    NSDictionary *address     = [addresses objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [address valueForKey:@"address"];
    cell.textLabel.text       = @"Location:";
    
    cell.detailTextLabel.numberOfLines = 0;
    [cell.detailTextLabel sizeToFit];
    
    return cell;
}


#pragma mark -
#pragma mark UITableViewDelegate methods
-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.noResults == YES) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedAddressFromGeocoding" object:[addresses objectAtIndex:indexPath.row]];
    
    [searchBar becomeFirstResponder];
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.noResults == YES) {
        return 45.0f;
    }

    NSDictionary *address = [addresses objectAtIndex:indexPath.row];
    NSString *text        = [address valueForKey:@"address"];
    UIFont *font          = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    UILineBreakMode bMode = UILineBreakModeWordWrap;
    
    CGFloat height    = [UITableViewCell calculateHeightFromWidth:227.0f text:text font:font lineBreakMode:bMode] + 25;
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
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
    [request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
    //[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
    [requests setObject:request forKey:identifier];
    
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    [manager
     addRequest:request
     withTag:identifier
     delegate:self
     didFinishSelector:@selector(getLocationsFinishWithData:)
     didFailSelector:@selector(getLocationsFailWithData:)
     ];
    
    [searchBar resignFirstResponder];
    
    for (id subview in [sBar subviews]) {
        if ([subview isKindOfClass:[UIButton class]]) {
            [subview setEnabled:TRUE];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:query forKey:@"address_search_query"];
    [statusView showLabel:@"Searching..." withSpinner:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)sBar {
    [self.navigationController dismissModalViewControllerAnimated:YES];
}

-(void) searchBar:(UISearchBar *)sBar textDidChange:(NSString *)searchText {
    if ([searchText isEqualToString:@""]) {
        [self setAddresses:[NSArray array]];
        [self.tableView reloadData];
    }
}

-(void) showNoResults {
    self.noResults = YES;
    [self setAddresses:[NSArray array]];
    [self.tableView reloadData];
    return;
}


#pragma mark -
#pragma mark Geocoding API delegates
-(void) getLocationsFinishWithData:(NSDictionary *)data {
    NSUInteger code = [(NSHTTPURLResponse *)[data objectForKey:@"response"] statusCode];
    NSData *payload = [data objectForKey:@"data"];
    NSString *tag   = [data objectForKey:@"tag"];
    
    [requests removeObjectForKey:tag];
    
    [statusView hideLabel];
    
    if(code != 200) {
        [self showAlertWithText:@"API error"];
        return;
    }
    
    NSDictionary *response = [[CJSONDeserializer deserializer] deserializeAsDictionary:payload error:nil];
    if (response == nil) {
        [self showNoResults];
        return;
    }
    
    NSString *status = [response objectForKey:@"status"];
    if (status == nil || ![status isEqualToString:@"OK"]) {
        [self showNoResults];
        return;
    }
    
    NSUInteger counter    = 0;
    NSMutableArray *items = [NSMutableArray array];
    NSArray *results      = [response objectForKey:@"results"];
    
    if (results == nil || [results count] < 1) {
        self.noResults = YES;
        [self setAddresses:[NSArray array]];
        [self.tableView reloadData];
        return;
    }
    
    self.noResults = NO;
    for (NSDictionary *result in results) {
        NSString *address      = [result valueForKey:@"formatted_address"];
        NSDictionary *geometry = [result valueForKey:@"geometry"];
        
        if (address == nil || geometry == nil) {
            continue;
        }
        
        NSDictionary *location = [geometry valueForKey:@"location"];
        if (location == nil) {
            continue;
        }
        float lat = [[location valueForKey:@"lat"] floatValue];
        float lng = [[location valueForKey:@"lng"] floatValue];
        
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
    
    [self showNoResults];
}

-(void) getLocationsFailWithData:(NSDictionary *)data {
    NSString *tag  = [data objectForKey:@"tag"];
    NSError *error = [data objectForKey:@"error"];
    
    [requests removeObjectForKey:tag];
    
    [self showAlertWithText:[error localizedDescription]];
    
    [statusView hideLabel];
    [self setAddresses:[NSArray array]];
}

@end



@implementation UITableViewCell (Custom)

+(float) calculateHeightFromWidth:(float)width text:(NSString *)text font:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode {
    [text retain];
    [font retain];
    
    CGSize suggestedSize = [text sizeWithFont:font constrainedToSize:CGSizeMake(width, FLT_MAX) lineBreakMode:lineBreakMode];
    
    [text release];
    [font release];
    
    return suggestedSize.height;
}

@end




