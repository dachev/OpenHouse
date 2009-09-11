//
//  NewConnectionManager.h
//  OpenHouses
//
//  Created by blago on 9/8/09.
//  Copyright 2009 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"


@interface NewConnectionManager : NSObject {
	CFMutableDictionaryRef requests;
	CFMutableDictionaryRef connections;
	CFMutableDictionaryRef callbacks;
}

+(NewConnectionManager *) sharedNewConnectionManager;
-(void) addRequest:(NSURLRequest *)request withTag:(NSString *)tag delegate:(id)d didFinishSelector:(SEL)finishSel didFailSelector:(SEL)failSel;
-(void) cancelRequest:(NSURLRequest *)request;

@end
