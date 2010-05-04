//
//  DiskCache.h
//  OpenHouse
//
//  Created by Blagovest Dachev on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import "Constants.h"
#import "SynthesizeSingleton.h"


@interface FileMetadata : NSObject {
    NSString *name;
    NSNumber *size;
    NSDate *modified;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber *size;
@property (nonatomic, retain) NSDate *modified;

@end



@interface DiskCache : NSObject {
    NSString *cachePath;
    NSMutableArray *fileList;
    NSMutableDictionary *fileTable;
    unsigned long long currentSize;
    unsigned long long maxSize;
}

@property (nonatomic, retain) NSString *cachePath;
@property (nonatomic, retain) NSMutableArray *fileList;
@property (nonatomic, retain) NSMutableDictionary *fileTable;
@property (nonatomic, assign) unsigned long long currentSize;
@property (nonatomic, assign) unsigned long long maxSize;

+(DiskCache *) sharedDiskCache;
-(NSData*) dataForRequest:(NSURLRequest*)request;
-(BOOL) storeData:(NSData*)data ForRequest:(NSURLRequest*)request;

@end
