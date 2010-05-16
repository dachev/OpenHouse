//
//  StatusView.m
//  OpenHouses
//
//  Created by blago on 7/29/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "StatusView.h"

@implementation StatusView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
    }
    return self;
}

-(void) showLabel:(NSString *)label withSpinner:(BOOL)spin {
    [self hideLabel];

    int viewWidth      = self.frame.size.width;
    int spinnerWidth   = (spin == YES) ? 20 : 0;
    
    NSString *statusText = label;
    int labelWidth       = (int) [statusText sizeWithFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]].width;
    int labelOffset      = (int) (viewWidth - (labelWidth + spinnerWidth + 6)) / 2;
    UILabel *statusLabel = [[[UILabel alloc] initWithFrame:CGRectMake(labelOffset,0,labelWidth,20)] autorelease];
    [statusLabel setBackgroundColor:[UIColor clearColor]];
    [statusLabel setTextColor:[UIColor whiteColor]];
    [statusLabel setFont:[UIFont systemFontOfSize:[UIFont systemFontSize]]];
    //[statusLabel setTextAlignment:UITextAlignmentCenter];
    [statusLabel setText:statusText];
    [self addSubview:statusLabel];
    
    if (spin == YES) {
        int spinnerOffset = labelOffset + labelWidth + 6;
        UIActivityIndicatorView *spinner = [[[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(spinnerOffset,0,spinnerWidth,20)] autorelease];
        [spinner startAnimating];
        [self addSubview:spinner];
    }
}

-(void) hideLabel {
    for (UIView *view in [self subviews]) {
        [view removeFromSuperview];
    }
}

/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
    [super dealloc];
}


@end
