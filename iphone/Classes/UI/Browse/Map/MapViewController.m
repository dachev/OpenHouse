//
//  MapViewController.m
//  OpenHouses
//
//  Created by Blagovest Dachev on 5/11/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//

#import "MapViewController.h"

@interface MapViewController (Private)
@end

@implementation MapViewController
@synthesize mapView, annotations;

#pragma mark -
#pragma mark Instantiation and tear down
-(id) initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
		[self setAnnotations:[NSArray array]];
    }
    return self;
}

-(void) dealloc {
	[mapView release];
	[annotations release];
	
    [super dealloc];
}


#pragma mark -
#pragma mark Standard UIViewController stuff
-(void) loadView {
	[super loadView];
	
	/* Initialize the map */
	[self setMapView:[[[MKMapView alloc] initWithFrame:CGRectMake(0,-20,320,372)] autorelease]];
	mapView.showsUserLocation = NO;
	mapView.mapType	          = MKMapTypeStandard;
	mapView.delegate          = self;
	
	[self.view addSubview:mapView];
}

-(void) viewDidLoad {
	[super viewDidLoad];
}

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
-(void) setLocation:(CLLocation *)loc {
	[mapView removeAnnotations:annotations];
    [self setAnnotations:[NSArray array]];
    
	/*Region and Zoom*/
	MKCoordinateRegion region;
	MKCoordinateSpan span;
	span.latitudeDelta  = 0.5;
	span.longitudeDelta = 0.5;
	
	region.span   = span;
	region.center = [loc coordinate];
	
	[mapView setRegion:region animated:TRUE];
}

-(void) showPage:(NSArray *)a withOrigin:(CLLocation *)origin {
	NSArray *oldAnnotations = a;
	[oldAnnotations retain];
	[self setAnnotations:a];
	
	/* Adjust the map viewport to fit all pins */
	float dLat = 0.0f;
	float dLng = 0.0f;
	
	for (OpenHouse *annotation in a) {
		dLat = MAX(dLat, fabs([mapView region].center.latitude  - annotation.coordinate.latitude));
		dLng = MAX(dLng, fabs([mapView region].center.longitude - annotation.coordinate.longitude));
	}
	
	dLat += dLat * 1.1;
	dLng += dLng * 1.1;
	
	MKCoordinateSpan span;
	span.latitudeDelta  = dLat;
	span.longitudeDelta = dLng;
	
	CLLocationCoordinate2D center;
	center.latitude  = origin.coordinate.latitude + 0.001f;
	center.longitude = origin.coordinate.longitude;
	
	MKCoordinateRegion region;
	region.center = center;
	region.span   = span;
	[mapView setRegion:region animated:NO];
	
	center.latitude -= 0.001f;
	[mapView setRegion:region animated:YES];
	
	/* Drop pins */
	[mapView removeAnnotations:oldAnnotations];
	[oldAnnotations release];
	[mapView addAnnotations:annotations];
}

-(void) showCallout {
	if ([self.view superview] != nil) {
		[mapView selectAnnotation:[annotations objectAtIndex:0] animated:YES];
	}
}

-(void) showCallout:(OpenHouse *)house {
	[mapView selectAnnotation:house animated:YES];
}

-(void) showDetails:(UIButton *)sender {
	OpenHouse *house = [(MKPinAnnotationView *)[[sender superview] superview] annotation];
	[[NSNotificationCenter defaultCenter] postNotificationName:@"selectedHouse" object:house];
}


#pragma mark ---- MKMapViewDelegate methods ----
- (MKAnnotationView *) mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>) annotation {
	MKPinAnnotationView *annView=[[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"] autorelease];
	annView.animatesDrop=YES;
	annView.canShowCallout=YES;
	
	if (annotation == [map userLocation]) {
		[annView setPinColor:MKPinAnnotationColorGreen];
	}
	else {
		UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
		[button addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
		annView.rightCalloutAccessoryView=button;
	}
	
	return annView;
}

-(void) mapView:(MKMapView *)map didAddAnnotationViews:(NSArray *)views {
	[self performSelector:@selector(showCallout) withObject:nil afterDelay:1];
}

//-(void) mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//NSLog(@"------");
//}


@end
