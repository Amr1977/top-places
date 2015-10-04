//
//  TPHistory.m
//  top-places
//
//  Created by Amr Lotfy on 10/3/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPHistory.h"
#import "FlickrFetcher.h"

#define USER_DEFAULTS_IDS_ARRAY_ENTRY_KEY @"top_places_ids_array"
#define USER_DEFAULTS_HISTORY_DICTIONARY_KEY @"top_places_history_dictionary"

@implementation TPHistory



+(instancetype) sharedInstance{
    static TPHistory * _sharedInstance=nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[TPHistory alloc] init];
        //restore history from user defaults, and make a mutable copy (as it is restored as immutable).
        _sharedInstance.photosIDsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_IDS_ARRAY_ENTRY_KEY] mutableCopy];
        _sharedInstance.photosHistory = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_HISTORY_DICTIONARY_KEY] mutableCopy];
    });
    
    return _sharedInstance;
}

-(instancetype) init{
    return [[self class] sharedInstance];
}

#define MAX_HISTORY_ENTRIES_COUNT 20

#define HISTORY_ENTRY_IMAGE_PATH_KEY @"path" //path of saved image file
#define HISTORY_ENTRY_IMAGE_INFO_KEY @"info" // photo info dictionary



/**
 Simply extract photo Id from imageInfo and keep a copy that ID in a separate array (photosIDsArray), insert new ids in index 0,  to preserve time order, then add the @{image,info} dictionary as a value in photosHistory dictionary with a key that is photo ID.
 
 Simply add to this dictionary @{photoid:@{image:image, info:imageInfo}}
 
 UPDATE: DON'T add the image data to the history structure, save it to a file and only add its path.
 */
+(void) addUIImage:(NSData *)image withInfo:(NSDictionary *)imageInfo{
    if (imageInfo && image ) {
        
        //TODO: only add if not already in the list, if in the list move it to the top
        NSString * photoID = imageInfo[FLICKR_PHOTO_ID];
        
        NSUInteger indexOfImage= [[TPHistory sharedInstance].photosIDsArray indexOfObject:photoID];
        
        if (indexOfImage == NSNotFound) {
            NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                                   NSUserDomainMask,
                                                                   YES);
            NSString *path = [[pathArr objectAtIndex:0]
                              stringByAppendingPathComponent:imageInfo[FLICKR_PHOTO_ID]];
            
            //save image data to file named with its photo id string
            [image writeToFile:path atomically:YES];
            
            //insert at the start/top
            [[TPHistory sharedInstance].photosIDsArray insertObject:photoID atIndex:0];
            NSDictionary * histryValueEntry= @{ HISTORY_ENTRY_IMAGE_INFO_KEY:imageInfo, HISTORY_ENTRY_IMAGE_PATH_KEY: path };
            [TPHistory sharedInstance].photosHistory[photoID]=histryValueEntry;
            [[NSUserDefaults standardUserDefaults] setObject:[TPHistory sharedInstance].photosIDsArray forKey:USER_DEFAULTS_IDS_ARRAY_ENTRY_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:[TPHistory sharedInstance].photosHistory forKey:USER_DEFAULTS_HISTORY_DICTIONARY_KEY];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            //TODO: check history list size and remove extra entries from both styructures, and delete the file from disk.
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
