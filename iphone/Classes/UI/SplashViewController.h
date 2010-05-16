//
//  SplashViewController.h
//  OpenHouse
//
//  Created by Blagovest Dachev on 5/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SplashViewController : UIViewController {
    UIImageView *background;
    UIActivityIndicatorView *spinner;
}

@property (nonatomic, retain) UIImageView *background;
@property (nonatomic, retain) UIActivityIndicatorView *spinner;

@end
