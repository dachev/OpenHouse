//
//  TaggedURLConnection.h
//  Icarus
//
//  Created by blago on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TaggedURLConnection : NSURLConnection {
	NSString *tag;
    NSInteger status;
}

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, assign) NSInteger status;

@end
