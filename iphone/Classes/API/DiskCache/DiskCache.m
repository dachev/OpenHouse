//
//  DiskCache.m
//  OpenHouse
//
//  Created by Blagovest Dachev on 5/3/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "DiskCache.h"


@interface FileMetadata (Private)
-(NSComparisonResult) lastUpdateCompare:(FileMetadata*)other;
@end

@implementation FileMetadata
@synthesize name, size, modified;

#pragma mark -
#pragma mark Object lifecycle
-(void) dealloc {
    [name release];
	[size release];
    [modified release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Comparitors
-(NSComparisonResult) lastUpdateCompare:(FileMetadata*)other {
    return [self.modified compare:other.modified];
}

@end



@interface DiskCache (Private)
-(BOOL) ensurePath;
-(BOOL) trimToAccomodate:(unsigned long long)bytes;
-(NSString*) getFilenameForURL:(NSString*)url;
@end

@implementation DiskCache
SYNTHESIZE_SINGLETON_FOR_CLASS(DiskCache);
@synthesize cachePath, fileList, fileTable, currentSize, maxSize;

#pragma mark -
#pragma mark Object lifecycle
-(id) init {
	if (self = [super init]) {
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
        NSString* cachesPath = [paths objectAtIndex:0];
        self.cachePath = [cachesPath stringByAppendingPathComponent:@"HTTP"];
        
        // create the cache dir if necessary
        [self ensurePath];
        
        // initialize members
        self.currentSize = 0;
        self.maxSize = DISK_CACHE_MAX_SIZE;
        self.fileList = [NSMutableArray array];
        self.fileTable = [NSMutableDictionary dictionary];
        
        // create internal memory structures
        NSFileManager *fm = [NSFileManager defaultManager];
        NSDirectoryEnumerator* e = [fm enumeratorAtPath:self.cachePath];
        for (NSString *fileName; fileName = [e nextObject]; ) {
            NSDictionary *fileAttr = [e fileAttributes];
            NSString *fileType = [fileAttr objectForKey:NSFileType];
            NSNumber *size = [fileAttr objectForKey:NSFileSize];
            NSDate *modified = [fileAttr objectForKey:NSFileModificationDate];
            
            if (![fileType isEqualToString:@"NSFileTypeRegular"]) {
                continue;
            }
            
            // thie total size of a FileMetadata object is ~= 96 bytes
            FileMetadata *meta = [[[FileMetadata alloc] init] autorelease];
            meta.size = size;
            meta.modified = modified;
            meta.name = fileName;
            
            [fileTable setObject:meta forKey:fileName];
            [fileList addObject:meta];
            
            self.currentSize += [size intValue];
        }
        
        NSLog(@"Cache size:%dK", self.currentSize/1024);
        
        // sort older to newer...
        [fileList sortUsingSelector:@selector(lastUpdateCompare:)];
        
        // make sure we are within maxSize limits
        [self trimToAccomodate:0];
	}
    
	return self;
}

-(void) dealloc {
	[cachePath release];
    [fileList release];
    [fileTable release];
    
	[super dealloc];
}

#pragma mark -
#pragma mark Business logic
-(BOOL) ensurePath {
    if (![[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
        return [[NSFileManager defaultManager]
                createDirectoryAtPath:self.cachePath 
                withIntermediateDirectories:YES
                attributes:nil 
                error:nil];
    }
    
    return YES;
}

-(BOOL) trimToAccomodate:(unsigned long long)bytes {
    if (bytes > self.maxSize) {
        return NO;
    }
    
    if (self.currentSize + bytes <= self.maxSize) {
        return YES;
    }
    
    while (self.currentSize + bytes > self.maxSize) {
        if ([self.fileList count] < 1) {
            return NO;
        }
        
        FileMetadata *meta = [fileList objectAtIndex:0];
        NSString *fileName = meta.name;
        unsigned long long fileSize = [meta.size intValue];
        
        NSString *filePath = [self.cachePath stringByAppendingPathComponent:fileName];
        NSFileManager *fm = [NSFileManager defaultManager];
        if (![fm removeItemAtPath:filePath error:nil]) {
            // hmm, should we bail out instead
            continue;
        }
        
        [self.fileList removeObjectAtIndex:0];
        [self.fileTable removeObjectForKey:fileName];
        
        self.currentSize -= fileSize;
    }
    
    if (self.currentSize + bytes > self.maxSize) {
        return NO;
    }
    
    return YES;
}

-(NSString*) filenameForURL:(NSString*)url {
	const char* str = [url UTF8String];
	unsigned char result[CC_MD5_DIGEST_LENGTH];
	CC_MD5(str, strlen(str), result);
	
	return [NSString stringWithFormat:
			@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
			result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
			result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
			];
}

-(NSData*) dataForRequest:(NSURLRequest*)request {
    NSString *fileName = [self filenameForURL:request.URL.absoluteString];
    
    if ([fileTable objectForKey:fileName] == nil) {
        return nil;
    }
    
    NSString *filePath = [self.cachePath stringByAppendingPathComponent:fileName];
    return [NSData dataWithContentsOfFile:filePath];
}

-(BOOL) hasData:(NSData*)data ForRequest:(NSURLRequest*)request {
    NSString *fileName = [self filenameForURL:request.URL.absoluteString];
    
    return [fileTable objectForKey:fileName] != nil;
}

-(BOOL) storeData:(NSData*)data ForRequest:(NSURLRequest*)request {
    NSString *fileName = [self filenameForURL:request.URL.absoluteString];
    
    if ([fileTable objectForKey:fileName] != nil) {
        return NO;
    }
    
    if (![self trimToAccomodate:[data length]]) {
        return NO;
    }
    
    // save file
    NSString *filePath = [self.cachePath stringByAppendingPathComponent:fileName];
    NSFileManager* fm = [NSFileManager defaultManager];
    if (![fm createFileAtPath:filePath contents:data attributes:nil]) {
        return NO;
    }
    
    // add to internal memory structures
    FileMetadata *meta = [[[FileMetadata alloc] init] autorelease];
    meta.size = [NSNumber numberWithInt:[data length]];
    meta.modified = [NSDate date];
    meta.name = fileName;
            
    [fileTable setObject:meta forKey:fileName];
    [fileList addObject:meta];
    
    return YES;
}

@end






