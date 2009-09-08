//
//  ImageTableController.m
//  OpenHouses
//
//  Created by blago on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "ImageTableController.h"

@interface UITableViewCell (Custom)
+(float) calculateHeightFromWidth:(float)width text:(NSString *)text font:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode;
@end

@interface ImageTableController (Private)
-(NSString *) makeRangeLabelforBegin:(NSDate *)begin end:(NSDate *)end;
@end


@implementation ImageTableController
@synthesize house;

#pragma mark -
#pragma mark Instantiation and tear down
/*
- (id)initWithStyle:(UITableViewStyle)style {
    // Override initWithStyle: if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
    if (self = [super initWithStyle:style]) {
    }
    return self;
}
*/

-(void)dealloc {
    [house release];
    
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

-(void) didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

-(void) viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


#pragma mark -
#pragma mark Custom methods
-(void) setHouse:(OpenHouse *)v {
    [v retain];
    [house release];
    house = v;
    
    [self.tableView reloadData];
}

-(NSString *) makeRangeLabelforBegin:(NSDate *)begin end:(NSDate *)end {
    NSString *text = @"";
    
    if (begin == nil) {
        return @"";
    }
    
    NSDateFormatter *formatter    = [[[NSDateFormatter alloc] init] autorelease];
    if (end == nil) {
        [formatter setDateFormat:OPEN_HOUSE_DATE_DATE];
        return [formatter stringFromDate:begin];
    }
    
    NSCalendar *calendar          = [[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar] autorelease];
    int calendarUnits             = kCFCalendarUnitYear|kCFCalendarUnitMonth|kCFCalendarUnitDay|kCFCalendarUnitHour|kCFCalendarUnitMinute|kCFCalendarUnitSecond;
    NSDateComponents *bcomponents = [calendar components:calendarUnits fromDate:begin];
    NSDateComponents *ecomponents = [calendar components:calendarUnits fromDate:end];
    BOOL isSameDate               = (bcomponents.year  == ecomponents.year) &&
    (bcomponents.month == ecomponents.month) &&
    (bcomponents.day   == ecomponents.day) ?
    YES : NO;
    
    if (!isSameDate) {
        [formatter setDateFormat:OPEN_HOUSE_DATE_DATE];
        text = [text stringByAppendingString:[formatter stringFromDate:begin]];
        text = [text stringByAppendingString:@", "];
        text = [text stringByAppendingString:[formatter stringFromDate:end]];
        
        return text;
    }
    
    if (bcomponents.hour == 0 || ecomponents.hour == 23) {
        [formatter setDateFormat:OPEN_HOUSE_DATE_DATE];
        text = [text stringByAppendingString:[formatter stringFromDate:begin]];
        
        return text;
    }
    
    [formatter setDateFormat:OPEN_HOUSE_DATE_TIME];
    text = [text stringByAppendingString:[formatter stringFromDate:begin]];
    text = [text stringByAppendingString:@" - "];
    text = [text stringByAppendingString:[formatter stringFromDate:end]];
    
    [formatter setDateFormat:OPEN_HOUSE_DATE_DATE];
    text = [text stringByAppendingString:@"\n"];
    text = [text stringByAppendingString:[formatter stringFromDate:begin]];
    
    return text;
}


#pragma mark -
#pragma mark UITableViewDataSource methods
-(NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 2;
    }
    if (section == 1) {
        return 1;
    }
    
    return 3;
}

-(UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row     = indexPath.row;
    
    NSString *CellIdentifier = @"value2";
    if (section == 1) {
        CellIdentifier = @"default";
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        if ([CellIdentifier isEqualToString:@"value2"]) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
            cell.detailTextLabel.numberOfLines = 0;
            [cell.detailTextLabel sizeToFit];
        }
        else {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        }
        
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (section == 0) {
        if (row == 0) {
            cell.textLabel.text       = @"address";
            cell.detailTextLabel.text = [house title];
        }
        else if (row == 1) {
            NSString *range           = [self makeRangeLabelforBegin:[house begin] end:[house end]];
            cell.textLabel.text       = @"open";
            cell.detailTextLabel.text = range;
        }
    }
    else if (section == 1) {
        if (row == 0) {
            // add photos
        }
    }
    else {
        cell.textLabel.text       = @"label";
        cell.detailTextLabel.text = @"value";
    }
	
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
-(void) tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
	OpenHouse *house = [currentAnnotations objectAtIndex:indexPath.row];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedHouse" object:house];
}
*/

-(CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger section = indexPath.section;
    NSUInteger row     = indexPath.row;
    
    if (section == 0) {
        UIFont *font          = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
        UILineBreakMode bMode = UILineBreakModeWordWrap;
        CGFloat height        = 0;
        
        if (row == 0) {
            NSString *text = [house title];
            height         = [UITableViewCell calculateHeightFromWidth:207.0f text:text font:font lineBreakMode:bMode] + 25;
        }
        else if (row == 1) {
            NSString *text = [self makeRangeLabelforBegin:[house begin] end:[house end]];
            height         = [UITableViewCell calculateHeightFromWidth:207.0f text:text font:font lineBreakMode:bMode] + 25;
        }
        
        if (height < 45.0f) {
            height = 45.0f;
        }
        
        return height;
    }
    if (section == 1) {
        return 200.0f;
    }
    
	return 40.0f;
}

@end

