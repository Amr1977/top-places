//
//  TPDataLoader.h
//  top-places
//
//  Created by Amr Lotfy on 9/29/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickerPhoto.h"

@interface TPDataLoader : NSObject


+(void) getFlickrTopPlacesWithCompletion:(void (^)(BOOL success, NSArray *result))completionBlock;

+(void) getPhotoListForFlickrPlace:(id)flickrPlaceId withCompletionBlock:(void (^)(BOOL success, NSArray *result))completionBlock;

+(void) getPhoto:(NSDictionary *)photo withCompletionBlock:(void (^)(BOOL success, NSData *result))completionBlock;

@end
