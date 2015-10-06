//
//  TPDataLoader.m
//  top-places
//
//  Created by Amr Lotfy on 9/29/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPDataLoader.h"
#import "FlickrFetcher.h"
@import UIKit;

//TODO: avoid repeated identical requests by checking before sending the request on a request-list and inserting current request in it.
@interface TPDataLoader ()
@property (strong,nonatomic) NSMutableArray * currentInProgressRequestsQueue;//TODO: use this queue to eliminate repeatred identical requests.

@end
@implementation TPDataLoader

+(void) getFlickrTopPlacesWithCompletion:(void (^)(BOOL , NSArray *))completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData * result= [NSData dataWithContentsOfURL:[FlickrFetcher URLforTopPlaces]];
        NSDictionary * parsedJSONDictionary = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        //NSLog(@"Top Places response dictionary: %@",parsedJSONDictionary);//OK
        if (result) {
            //NSLog(@"**************** [%@] Top Places response dictionary: %@",NSStringFromSelector(_cmd),parsedJSONDictionary);//OK
            NSDictionary * placesResults=parsedJSONDictionary[@"places"];
            NSArray * topPlacesArray = placesResults[@"place"];
            //NSLog(@"top places array: %@", topPlacesArray);
            //NSLog(@"Fetched [%lu] place.",(unsigned long)topPlacesArray.count);
            if (completionBlock) {
                completionBlock(true,topPlacesArray);
            }
        }else{
            NSLog(@"!!!!!!!!!!!!!!!! [%@] Error fetching top places, %@",NSStringFromSelector(_cmd),[FlickrFetcher URLforTopPlaces]);
        }
    });
}

#define MAX_PHOTOS_COUNT 50

+(void) getPhotoListForFlickrPlace:(id)flickrPlaceId withCompletionBlock:(void (^)(BOOL success, NSArray *result))completionBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData * result= [NSData dataWithContentsOfURL:[FlickrFetcher URLforPhotosInPlace:flickrPlaceId maxResults:MAX_PHOTOS_COUNT]];
        NSDictionary * parsedJSONDictionary = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        if (result) {
            //NSLog(@"**************** [%@] PHOTO list response dictionary: %@",NSStringFromSelector(_cmd),parsedJSONDictionary);//OK
            NSDictionary * photosResults=parsedJSONDictionary[@"photos"];
            NSArray * photosArray = photosResults[@"photo"];
            //NSLog(@"top places array: %@", topPlacesArray);
            //NSLog(@"Fetched [%lu] place.",(unsigned long)topPlacesArray.count);
            if (completionBlock) {
                completionBlock(true,photosArray);
            }
        }else{
            NSLog(@"!!!!!!!!!!!!!!!! Error fetching photos, [%@]",[FlickrFetcher URLforPhotosInPlace:flickrPlaceId maxResults:MAX_PHOTOS_COUNT]);
        }
    });
}

//TODO: check cached history, if image already exists (same id) load from local history.
+(void) getPhoto:(NSDictionary *)photo withCompletionBlock:(void (^)(BOOL success, NSData *result))completionBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData * result = [NSData dataWithContentsOfURL:[FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge]];
        if (result) {
            NSLog(@"**************** PHOTO Data received successfully");//OK
            if (completionBlock) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionBlock(true,result);
                });
            }
        }else{
            NSLog(@"!!!!!!!!!!!!!!!! Error fetching photo, [%@]",[FlickrFetcher URLforPhoto:photo format:FlickrPhotoFormatLarge]);
        }
    });
}
@end
