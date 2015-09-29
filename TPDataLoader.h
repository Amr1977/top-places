//
//  TPDataLoader.h
//  top-places
//
//  Created by Amr Lotfy on 9/29/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FlickerPhoto.h"
#import "FlickerPlace.h"

@interface TPDataLoader : NSObject

+(void) getFlickrTopPlacesWithCompletion:(void (^)(BOOL success, NSArray *result))completionBack;

+(void) getPhotoListForFlickrPlace:(FlickerPlace *)flickrPlace withCompletionBlock:(void (^)(BOOL success, NSArray *result))completionBack;

+(void) getPhoto:(FlickerPhoto *)photo withCompletionBlock:(void (^)(BOOL success, NSData *result))completionBack;

@end
