//
//  TaggedRequest.h
//  Icarus
//
//  Created by blago on 5/18/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TaggedRequest : NSMutableURLRequest {
	NSString *tag;
	
	id delegate;
	SEL finishSelector;
	SEL failSelector;
}

@property (nonatomic, retain) NSString *tag;
@property (nonatomic, retain, readonly) id delegate;
@property (nonatomic, assign, readonly) SEL finishSelector;
@property (nonatomic, assign, readonly) SEL failSelector;

+(TaggedRequest *) requestWithId:(NSString *)identifier url:(NSString *)urlString;
-(void) delegate:(id)d didFinishSelector:(SEL)finishSel didFailSelector:(SEL)failSel;

@end
