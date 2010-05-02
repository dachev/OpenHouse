//
//  AddressResultCell.m
//  OpenHouses
//
//  Created by blago on 9/7/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import "AddressResultCell.h"


@interface UITableViewCell (Custom)
+(float) calculateHeightFromWidth:(float)width text:(NSString *)text font:(UIFont *)font lineBreakMode:(UILineBreakMode)lineBreakMode;
@end


@implementation AddressResultCell

-(void) dealloc {
    [super dealloc];
}

-(void) layoutSubviews {
    [super layoutSubviews];
    
    NSString *text        = self.detailTextLabel.text;
    UIFont *font          = [UIFont fontWithName:@"HelveticaNeue-Bold" size:15];
    UILineBreakMode bMode = UILineBreakModeWordWrap;
    
    CGFloat height = [UITableViewCell calculateHeightFromWidth:227.0f text:text font:font lineBreakMode:bMode];
    self.detailTextLabel.frame = CGRectMake(self.detailTextLabel.frame.origin.x, 12.0f, self.detailTextLabel.frame.size.width, height);
}


@end
