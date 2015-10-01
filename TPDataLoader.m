//
//  TPDataLoader.m
//  top-places
//
//  Created by Amr Lotfy on 9/29/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPDataLoader.h"
#import "FlickrFetcher.h"

@implementation TPDataLoader

+(void) getFlickrTopPlacesWithCompletion:(void (^)(BOOL , NSArray *))completionBlock{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData * result= [NSData dataWithContentsOfURL:[FlickrFetcher URLforTopPlaces]];
        NSDictionary * parsedJSONDictionary = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        //NSLog(@"Top Places response dictionary: %@",parsedJSONDictionary);//OK
        if (result) {
            NSDictionary * placesResults=parsedJSONDictionary[@"places"];
            NSArray * topPlacesArray = placesResults[@"place"];
            //NSLog(@"top places array: %@", topPlacesArray);
            //NSLog(@"Fetched [%lu] place.",(unsigned long)topPlacesArray.count);
            if (completionBlock) {
                completionBlock(true,topPlacesArray);
            }
        }else{
            NSLog(@"Error fetching top places, %@",[FlickrFetcher URLforTopPlaces]);
        }
    });
}

#define MAX_PHOTOS_COUNT 50

+(void) getPhotoListForFlickrPlace:(id)flickrPlaceId withCompletionBlock:(void (^)(BOOL success, NSArray *result))completionBlock{
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSData * result= [NSData dataWithContentsOfURL:[FlickrFetcher URLforPhotosInPlace:flickrPlaceId maxResults:MAX_PHOTOS_COUNT]];
        NSDictionary * parsedJSONDictionary = [NSJSONSerialization JSONObjectWithData:result options:0 error:nil];
        NSLog(@"PHOTO list response dictionary: %@",parsedJSONDictionary);//OK
        if (result) {
            NSDictionary * photosResults=parsedJSONDictionary[@"photos"];
            NSArray * photosArray = photosResults[@"photo"];
            //NSLog(@"top places array: %@", topPlacesArray);
            //NSLog(@"Fetched [%lu] place.",(unsigned long)topPlacesArray.count);
            if (completionBlock) {
                completionBlock(true,photosArray);
            }
        }else{
            NSLog(@"Error fetching photos, [%@]",[FlickrFetcher URLforPhotosInPlace:flickrPlaceId maxResults:MAX_PHOTOS_COUNT]);
        }
    });
}

+(void) getPhoto:(FlickerPhoto *)photo withCompletionBlock:(void (^)(BOOL success, NSData *result))completionBack{
    NSLog(@"Not yet implemented.[3]");
}
@end
