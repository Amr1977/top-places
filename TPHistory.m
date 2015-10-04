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


/**
 Simply extract photo Id from imageInfo and keep a copy that ID in a separate array (photosIDsArray), insert new ids in index 0,  to preserve time order, then add the @{image,info} dictionary as a value in photosHistory dictionary with a key that is photo ID.
 
 Simply add to this dictionary @{photoid:@{image:image, info:imageInfo}}
 */
+(void) addUIImage:(UIImage *)image withInfo:(NSDictionary *)imageInfo{
    if (imageInfo && image ) {
        //TODO: only add if not already in the list, if in the list move it to the top
        NSString * photoID = imageInfo[FLICKR_PHOTO_ID];
        
        NSUInteger indexOfImage= [[TPHistory sharedInstance].photosIDsArray indexOfObject:photoID];
        
        if (indexOfImage == NSNotFound) {
            //insert at the start/top
            [[TPHistory sharedInstance].photosIDsArray insertObject:photoID atIndex:0];
            NSDictionary * histryValueEntry= @{ @"info":imageInfo, @"image": image };
            [TPHistory sharedInstance].photosHistory[photoID]=histryValueEntry;
            //TODO: check history list size and remove extra entries from both styructures
        }else{
            //move it to the start/top
            [[TPHistory sharedInstance].photosIDsArray removeObject:photoID];//remove from current position
            [[TPHistory sharedInstance].photosIDsArray insertObject:photoID atIndex:0];//insert at index 0
        }
    }
}

-(NSMutableDictionary *) photosHistory{
    if (!_photosHistory) {
        _photosHistory= [@{} mutableCopy];
    }
    return _photosHistory;
}

+(BOOL) photoExistsInHistory:(NSString *)photoID{
    BOOL result=[[TPHistory sharedInstance].photosIDsArray containsObject:photoID];
    return result;
}
@end
