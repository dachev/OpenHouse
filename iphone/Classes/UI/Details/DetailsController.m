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
-(void) showHouse;
-(void) loadScrollView:(UIView *)view withPage:(int)page;
-(void) cancelRequests;
@end

@implementation DetailsController
@synthesize pageControl, scrollView, specsView, house, imageURLs, pages, requests, pageControlUsed;

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
    [imageURLs release];
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
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    
    for (id key in requests) {
        NSURLRequest *request = [requests objectForKey:key];
        [manager cancelRequest:request];
    }
}

-(void) requestImage:(NSTimer*)theTime {
    NSNumber *info        = (NSNumber*)[theTime userInfo];
    NSString *urlString   = [imageURLs objectAtIndex:[info intValue]];
    NSURL *url            = [NSURL URLWithString:urlString];
    NSString *identifier  = [info stringValue];
    
    if (url == nil) {
        NSLog(@"%@", urlString);
        NSLog(@"%@", url);
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    //NSLog(@"%@", request.URL);
    [request setTimeoutInterval:CONFIG_NETWORK_TIMEOUT];
    [requests setObject:request forKey:identifier];
        
    ConnectionManager *manager = [ConnectionManager sharedConnectionManager];
    [manager addRequest:request
                withTag:identifier
               delegate:self
      didFinishSelector:@selector(getPhotoFinishWithData:)
        didFailSelector:@selector(getPhotoFailWithData:)
             checkCache:YES
            saveToCache:YES
        ];
}

-(void) setHouse:(OpenHouse *)v {
    [v retain];
    [house release];
    house = v;
    
    self.imageURLs = [NSMutableArray arrayWithArray:house.imageLinks];
    
    double lat       = house.coordinate.latitude;
    double lng       = house.coordinate.longitude;
    NSString *pipe   = @"%7C";
    NSString *colon  = @"%3A";
    NSString *mapURL = [NSString stringWithFormat:STATIC_MAPS_REQUEST_URL, lat, lng, colon, pipe, colon, pipe, lat, lng];
    NSLog(@"%@", mapURL);
    [imageURLs insertObject:mapURL atIndex:0];
    
    self.pages = [imageURLs count];
    if (pages > 20) {
        pages = 20;
    }
    
    [self setScrollView:[[[UIScrollView alloc] initWithFrame:CGRectMake(0,0,320,CONFIG_PAGE_VIEW_HEIGHT)] autorelease]];
    scrollView.backgroundColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
    scrollView.pagingEnabled = YES;
    scrollView.contentSize = CGSizeMake(scrollView.frame.size.width * (pages), scrollView.frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    scrollView.scrollsToTop = NO;
    scrollView.delegate = self;
    
    [self setPageControl:[[[UIPageControl alloc] initWithFrame:CGRectMake(0,0,320,20)] autorelease]];
    [pageControl addTarget:self action:@selector(changePage:) forControlEvents:UIControlEventValueChanged];
    pageControl.backgroundColor = [UIColor colorWithRed:145/255.0 green:145/255.0 blue:145/255.0 alpha:1.0];
    pageControl.numberOfPages = pages;
    pageControl.currentPage = 0;
    
    UIView *separator = [[[UIView alloc] initWithFrame:CGRectMake(0,CONFIG_PAGE_VIEW_HEIGHT+10,320,1)] autorelease];
    separator.backgroundColor = [UIColor colorWithRed:218/255.0 green:218/255.0 blue:218/255.0 alpha:1.0];
    
    SpecsView *sv = [[[SpecsView alloc] initWithFrame:CGRectZero] autorelease];
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
    
	for (int idx = 0; idx < [imageURLs count]; idx++) {
        if (idx > 0) {
            NSString *imageUrl        = [imageURLs objectAtIndex:idx];
            NSString *encodedImageUrl = [NSString encodeURIComponent:imageUrl];
            NSString *fullUrlString   = [NSString stringWithFormat:IMAGE_API_REQUEST_URL, @"f", encodedImageUrl];
        
            [imageURLs replaceObjectAtIndex:idx withObject:fullUrlString];
        }
    
        [NSTimer scheduledTimerWithTimeInterval:0.025*idx
                                         target:self
                                       selector:@selector(requestImage:)
                                       userInfo:[NSNumber numberWithInt:idx]
                                        repeats:NO];
    }
}

-(void) scrollViewDidScroll:(UIScrollView *)sender {
    if (pageControlUsed) {
        return;
    }
    
    CGFloat pageWidth = scrollView.frame.size.width;
    int page = floor((scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    pageControl.currentPage = page;
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
-(void) getPhotoFinishWithData:(NSDictionary *)data {
    // remove request from container
    NSHTTPURLResponse *resp = (NSHTTPURLResponse *)[data objectForKey:@"response"];
    NSData *payload         = [data objectForKey:@"data"];
    NSString *tag           = [data objectForKey:@"tag"];
    
    [requests removeObjectForKey:tag];
    
    if(resp && [resp statusCode] != 200) {
        return;
    }
    
    // Create view
    NSUInteger page        = (NSUInteger) [tag intValue];
    UIImage *image         = [UIImage imageWithData:payload];
    UIImageView *imageView = [[[UIImageView alloc] initWithImage:image] autorelease];
    
    // Adjust view size
    CGRect frame      = imageView.frame;
    frame.size.width  = [image size].width;
    frame.size.height = [image size].height;
    imageView.frame   = frame;
    
    // Insert into scoll parent
    [self loadScrollView:imageView withPage:page];
}

-(void) getPhotoFailWithData:(NSDictionary *)data {
    NSString *tag  = [data objectForKey:@"tag"];
    
    [requests removeObjectForKey:tag];
    
    //NSError *error = [data objectForKey:@"error"];
    //NSLog(@"%@:%@", tag, [error localizedDescription]);
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"thumbRequestFailed" object:error];
}


@end
