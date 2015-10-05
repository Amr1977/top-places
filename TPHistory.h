//
//  TPHistory.h
//  top-places
//
//  Created by Amr Lotfy on 10/3/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

#define MAX_HISTORY_ENTRIES_COUNT 20

#define HISTORY_ENTRY_IMAGE_PATH_KEY @"path" //path of saved image file
#define HISTORY_ENTRY_IMAGE_INFO_KEY @"info" // photo info dictionary

@interface TPHistory : NSObject

@property (strong,nonatomic) NSMutableDictionary * photosHistory;

@property (strong,nonatomic) NSMutableArray * photosIDsArray;


+(void) addImageData:(NSData *) image withInfo:(NSDictionary *)imageInfo;

+(instancetype) sharedInstance;

+(BOOL) photoExistsInHistory:(NSString *)photoID;

+(void) updateUserDefaults;
@end
