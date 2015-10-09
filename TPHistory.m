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
    });
    
    return _sharedInstance;
}

-(instancetype) init{
    self=[super init];
    NSLog(@"initializing TPHistory instance...");
    if (self) {
        NSLog(@"valid self created.");
        //restore history from user defaults, and make a mutable copy (as it is restored as immutable).
        _photosIDsArray = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_IDS_ARRAY_ENTRY_KEY] mutableCopy];
        _photosHistory = [[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_HISTORY_DICTIONARY_KEY] mutableCopy];
       
        
        //NSLog(@"IDs array: %@",_photosIDsArray);
       // NSLog(@"photos history: %@", _photosHistory);
    }
    return self;
}





/**
 Simply extract photo Id from imageInfo and keep a copy that ID in a separate array (photosIDsArray), insert new ids in index 0,  to preserve time order, then add the @{image,info} dictionary as a value in photosHistory dictionary with a key that is photo ID.
 
 Simply add to this dictionary @{photoid:@{image:image, info:imageInfo}}
 
 UPDATE: DON'T add the image data to the history structure, save it to a file and only add its path.
 */
+(void) addImageData:(NSData *)image withInfo:(NSDictionary *)imageInfo{
    if (imageInfo && image ) {
        
        //TODO: only add if not already in the list, if in the list move it to the top
        NSString * photoID = imageInfo[FLICKR_PHOTO_ID];
        
        //NSUInteger indexOfImage= [[TPHistory sharedInstance].photosIDsArray indexOfObject:photoID];
        
        //NSLog(@"image index in the history list: %lu",(unsigned long)indexOfImage);
        if (![[TPHistory sharedInstance].photosIDsArray containsObject:photoID]) {
            NSLog(@"entry not exists [%@], creating history entry ....",  photoID);
            NSArray *pathArr = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
            NSString *path = [[pathArr objectAtIndex:0]
                              stringByAppendingPathComponent:imageInfo[FLICKR_PHOTO_ID]];
            
            //save image data to file named with its photo id string
            if ([image writeToFile:path atomically:YES]){
                 NSLog(@"Saved file to path: [%@]",path);
            }else{
                NSLog(@"<<<<<<<>>>>>>> error saving file [%@]", path);
            }
            
            //insert at the start/top
            [[TPHistory sharedInstance].photosIDsArray insertObject:photoID atIndex:0];
            NSDictionary * histryValueEntry= @{ HISTORY_ENTRY_IMAGE_INFO_KEY:imageInfo, HISTORY_ENTRY_IMAGE_PATH_KEY: path };
            [TPHistory sharedInstance].photosHistory[photoID]=histryValueEntry;
            
            // check history list size and remove extra entries from both styructures, and delete the file from disk.
            if ([TPHistory sharedInstance].photosIDsArray.count > MAX_HISTORY_ENTRIES_COUNT) {
                NSLog(@"maximum history limit exceeded [%d], truncating old entries ....",MAX_HISTORY_ENTRIES_COUNT);
                NSString * photoToBeDeletedID=[TPHistory sharedInstance].photosIDsArray.lastObject;
                [[TPHistory sharedInstance].photosIDsArray removeLastObject];
                
                NSDictionary * historyEntry= [TPHistory sharedInstance].photosHistory[photoToBeDeletedID];
                
                //delete file
                
                if([TPHistory removeFile:historyEntry[HISTORY_ENTRY_IMAGE_PATH_KEY]]){
                    NSLog(@"removed file [%@]", path);
                }else{
                    NSLog(@"<<<<<<<<< error removing file [%@]", path);
                }

                //delete history entry
                
                [[TPHistory sharedInstance].photosHistory removeObjectForKey:photoToBeDeletedID];
            }
        }else{
            NSLog(@"entry already exists [%@]",photoID);
            //move it to the start/top
            if ([[TPHistory sharedInstance].photosIDsArray indexOfObject:photoID]!=0) {
                [[TPHistory sharedInstance].photosIDsArray removeObject:photoID];//remove from current position
                [[TPHistory sharedInstance].photosIDsArray insertObject:photoID atIndex:0];//insert at index 0
            }
        }
        [TPHistory updateUserDefaults];
    } else{
        NSLog(@"invalid parameters: [%@] , [%@].",image, imageInfo );
    }
}

+(BOOL) removeFile:(NSString *)filePath{
    NSLog(@"Attempting to delete file [%@]",filePath);
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL result = [fileManager removeItemAtPath:filePath error:&error];
    NSLog(@" result: [%@]", result? @"File Deleted.":@"Error deleting file.");
    return result;
}

+(void) updateUserDefaults{
    NSLog(@"Updating NSUserDefaults ...");
    [[NSUserDefaults standardUserDefaults] setObject:[[TPHistory sharedInstance].photosIDsArray copy] forKey:USER_DEFAULTS_IDS_ARRAY_ENTRY_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:[[TPHistory sharedInstance].photosHistory copy] forKey:USER_DEFAULTS_HISTORY_DICTIONARY_KEY];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"Updating NSUserDefaults Done");
    //NSLog(@"Updated user defaults structures: photosIDsArray: %@, /n photosHistory: %@",[[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_IDS_ARRAY_ENTRY_KEY], [[NSUserDefaults standardUserDefaults] objectForKey:USER_DEFAULTS_HISTORY_DICTIONARY_KEY]);
}

-(NSMutableDictionary *) photosHistory{
    if (!_photosHistory) {
        _photosHistory= [@{} mutableCopy];
    }
    return _photosHistory;
}

-(NSMutableArray *) photosIDsArray{
    if (!_photosIDsArray){
        _photosIDsArray= [@[] mutableCopy];
    }
    return _photosIDsArray;
}

+(BOOL) isPhotoIDExistInHistory:(NSString *)photoID{
    BOOL result=[[TPHistory sharedInstance].photosIDsArray containsObject:photoID];
    NSLog(@"Photo [%@] %@ in history.",photoID, result?@"Exists":@"Does NOT Exist");
    return result;
}

+(void) cleanHistory{
    if ([TPHistory sharedInstance].photosHistory.count>0) {
        
        //Collect entries in the history of non-existing files
        NSMutableArray * entriesToBeDeleted=[@[] mutableCopy];
        for (NSString * photoID in [TPHistory sharedInstance].photosIDsArray) {
            NSString * filePath=[TPHistory sharedInstance].photosHistory[photoID][HISTORY_ENTRY_IMAGE_PATH_KEY];
            if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                NSLog(@"Removeing History entry for [%@]",filePath);
                [entriesToBeDeleted addObject:photoID];
            }
        }
        
        //Clean up orphan history entries
        for (NSString * photoID in entriesToBeDeleted) {
            NSLog(@"Removing History entry for photoID: [%@]",photoID);
            [[TPHistory sharedInstance].photosIDsArray removeObject:photoID];
            [[TPHistory sharedInstance].photosHistory removeObjectForKey:photoID];
        }
        if (entriesToBeDeleted.count > 0) {
            NSLog(@"Cleanned invalid History entries.");
            [TPHistory updateUserDefaults];
        }
    }
}
@end
