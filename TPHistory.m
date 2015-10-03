//
//  TPHistory.m
//  top-places
//
//  Created by Amr Lotfy on 10/3/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPHistory.h"
#import "FlickrFetcher.h"

@implementation TPHistory



+(instancetype) sharedInstance{
    static TPHistory * _sharedInstance=nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[TPHistory alloc] init];
    });
    
    return _sharedInstance;
}

-(instancetype) init{
    return [[self class] sharedInstance];
}

#define MAX_HISTORY_ENTRIES_COUNT 20

#define HISTORY_ENTRY_IMAGE_DATA_KEY @"image"
#define HISTORY_ENTRY_IMAGE_INFO_KEY @"info"

-(void) addUIImage:(UIImage *)image withInfo:(NSDictionary *)imageInfo{
    if (imageInfo && image ) {
        //TODO: only add if not already in the list, if in the list move it to the top
        NSString * photoID = imageInfo[FLICKR_PHOTO_ID];
        
        NSUInteger indexOfImage= [self.photosIDsArray indexOfObject:photoID];
        
        if (indexOfImage == NSNotFound) {
            //DO insert at the start/top
            
            [self.photosIDsArray insertObject:photoID atIndex:0];
            NSDictionary * histryValueEntry= @{ @"info":imageInfo, @"image": image };
            self.photosHistory[photoID]=histryValueEntry;
            
            
        }else{
            //move it to the start/top
        }
        
        
    }
}

-(NSMutableArray *) photosInfoHistory{
    if (!_photosHistory) {
        _photosHistory= [@[] mutableCopy];
    }
    return _photosHistory;
}

@end
