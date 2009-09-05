//
//  DetailsController.m
//  OpenHouses
//
//  Created by blago on 7/1/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "DetailsController.h"

@interface NSString (Custom)
+(NSString *) encodeURIComponent: (NSString *) url;
@end

@interface DetailsController (Private)
-(void) loadScrollView:(UIView *)view withPage:(int)page;
-(void) cancelRequests;
@end

@implementation DetailsController
@synthesize pageControl, scrollView, specsView, house, pages, requests, pageControlUsed;

-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self setRequests:[NSMutableDictionary dictionary]];
    }
    
    return self;
}

-(void) dealloc {
	[self cancelRequests];
    
    [pageControl release];
    [scrollView release];
    [requests release];
    [specsView release];
    [house release];
    
    [super dealloc];
}

-(void) loadView {
	[self setView:[[[UIScrollView alloc] initWithFrame:CGRectZero] autorelease]];
    self.view.backgroundColor = [UIColor colorWithRed:202/255.0 green:202/255.0 blue:202/255.0 alpha:1.0];
}

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
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

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

-(void) cancelRequests {
	for (id key in requests) {
        TaggedRequest *request = [requests objectForKey:key];
        [request delegate:nil didFinishSelector:nil didFailSelector:nil];
    }
}

-(void) setHouse:(OpenHouse *)v {
    [v retain];
    [house release];
    house = v;
    
    self.pages = [house.imageLinks count];
    if (pages > 20) {
        pages = 20;
    }
    
    [self setScrollView:[[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,CONFIG_PAGE_VIEW_HEIGHT)] autorelease]];
    //[self setScrollView:[[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,253)] autorelease]];
    //scrollView.backgroundColor = [UIColor whiteColor];
    scrollView.backgroundColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
	scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * (pages+1), scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    [self setPageControl:[[[UIPageControl alloc] initWithFrame:CGRectMake(0,0,320,20)] autorelease]];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    //pageControl.backgroundColor = [UIColor clearColor];
    pageControl.backgroundColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
    pageControl.numberOfPages = pages+1;
	pageControl.currentPage = 0;
    
    UIView *separator = [[[UIView alloc] initWithFrame:CGRectMake(0,CONFIG_PAGE_VIEW_HEIGHT+10,320,1)] autorelease];
    //UIView *separator = [[[UIView alloc] initWithFrame:CGRectMake(0,245,320,1)] autorelease];
    separator.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    
    //[self loadScrollViewWithPage:0];
    SpecsView *sv = [[[SpecsView alloc] initWithFrame:CGRectZero] autorelease];
    //SpecsView *sv = [[[SpecsView alloc] initWithFrame:CGRectMake(0,263,320,437)] autorelease];
    [sv setHouse:house];
    [self setSpecsView:sv];
    
    [self.view addSubview:scrollView];
    [self.view addSubview:pageControl];
    [self.view addSubview:specsView];
    [self.view addSubview:separator];
    
    /* Adjust page controll position and size */
    [pageControl sizeToFit];
    CGRect rect = pageControl.frame;
    rect.origin.y = CONFIG_PAGE_VIEW_HEIGHT-10;
    rect.size.height = 20;
    pageControl.frame = rect;
    
    /* Adjust specs view position and size */
    CGRect frame = specsView.frame;
    frame.size.height = [specsView vOffset];
    frame.origin.y = CONFIG_PAGE_VIEW_HEIGHT+10;
    specsView.frame = frame;
    ((UIScrollView *)self.view).contentSize = CGSizeMake(320, CONFIG_PAGE_VIEW_HEIGHT+20+specsView.frame.size.height);
    
    int idx = 0;
	for (NSString *link in [house imageLinks]) {
		NSString *photoLink = [NSString encodeURIComponent:link];
		NSString *url       = [NSString stringWithFormat:IMAGE_API_REQUEST_URL, @"f", photoLink];
		
		NSString *identifier   = [NSString stringWithFormat:@"%d", idx];
		TaggedRequest *request = [TaggedRequest requestWithId:identifier url:url];
		[request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
		//[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
		[request delegate:self didFinishSelector:@selector(getPhotoFinish:withData:) didFailSelector:@selector(getPhotoFail:withError:)];
        [requests setObject:request forKey:identifier];
		
		ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
		[manager add:request];
        idx++;
	}
    
    // Create static map view
    NSString *htmlPath = [[NSBundle mainBundle] pathForResource:@"map" ofType:@"html"];
    float lat          = house.coordinate.latitude;
    float lng          = house.coordinate.longitude;
    NSString *url      = [NSString stringWithFormat:STATIC_MAPS_REQUEST_URL, lat, lng, lat, lng];
    NSString *html     = [NSString stringWithFormat:[NSString stringWithContentsOfFile:htmlPath], url];
    UIWebView *mapView = [[[UIWebView alloc] initWithFrame:CGRectMake(0,0,310,233)] autorelease];
    
    // Add map view
    [mapView loadHTMLString:html baseURL:nil];
    [self loadScrollView:mapView withPage:pages];
}

-(void) scrollViewDidScroll:(UIScrollView *)sender {
    if (pageControlUsed) {
        return;
    }
    
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
    
    //[self loadScrollViewWithPage:page - 1];
    //[self loadScrollViewWithPage:page];
    //[self loadScrollViewWithPage:page + 1];
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
-(void) scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.pageControlUsed = NO;
}

-(void) scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    self.pageControlUsed = NO;
}

-(void) changePage:(id)sender {
    int page = pageControl.currentPage;
    //[self loadScrollViewWithPage:page - 1];
    //[self loadScrollViewWithPage:page];
    //[self loadScrollViewWithPage:page + 1];
    
    // update the scroll view to the appropriate page
    CGRect frame = scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [scrollView scrollRectToVisible:frame animated:YES];
    
    self.pageControlUsed = YES;
}

-(void) loadScrollView:(UIView *)view withPage:(int)page {
    NSUInteger width  = view.frame.size.width;
    NSUInteger height = view.frame.size.height;
    CGRect frame      = scrollView.frame;
    
    int pageXOrigin = frame.size.width * page;
    int pageYOrigin = 0;
    int xDiff = (320 - width);
    int yDiff = (CONFIG_PAGE_VIEW_HEIGHT - height);
    
    frame.origin.x    = pageXOrigin + xDiff/2.0;
    frame.origin.y    = pageYOrigin + yDiff/2.0;
    frame.size.width  = width;
    frame.size.height = height;
    view.frame   = frame;
    
    UIView *separator1 = [[[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, width, 1)] autorelease];
    UIView *separator2 = [[[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y+height-1, width, 1)] autorelease];
    UIView *separator3 = [[[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x, view.frame.origin.y, 1, height)] autorelease];
    UIView *separator4 = [[[UIView alloc] initWithFrame:CGRectMake(view.frame.origin.x+width-1, view.frame.origin.y, 1, height)] autorelease];
    separator1.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    separator2.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    separator3.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    separator4.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    
    [scrollView addSubview:view];
    [scrollView addSubview:separator1];
    [scrollView addSubview:separator2];
    [scrollView addSubview:separator3];
    [scrollView addSubview:separator4];
}

#pragma mark -
#pragma mark Image API delegates
-(void) getPhotoFinish:(TaggedURLConnection *)connection withData:(NSData *)data {
    // remove request from container
    [requests removeObjectForKey:[connection tag]];
    
    if([connection status] != 200) {
        return;
    }
    
    // Create view
	NSUInteger page        = (NSUInteger) [[connection tag] intValue];
    UIImage *image         = [UIImage imageWithData:data];
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    
    // Adjust view size
    CGRect frame      = imageView.frame;
    frame.size.width  = [image size].width;
    frame.size.height = [image size].height;
    imageView.frame   = frame;
    
    // Insert into scoll parent
    [self loadScrollView:imageView withPage:page];
}

-(void) getPhotoFail:(TaggedURLConnection *)connection withError:(NSString *)error {
    [requests removeObjectForKey:[connection tag]];
    
	//NSLog(@"%@:%@", [connection tag], error);
	//[[NSNotificationCenter defaultCenter] postNotificationName:@"thumbRequestFailed" object:error];
}


@end
