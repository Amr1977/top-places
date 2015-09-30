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
        NSLog(@"Top Places response dictionary: %@",parsedJSONDictionary);//OK
        if (result) {
            NSDictionary * placesResults=parsedJSONDictionary[@"places"];
            NSArray * topPlacesArray = placesResults[@"place"];
            NSLog(@"top places array: %@", topPlacesArray);
            NSLog(@"Fetched [%lu] place.",(unsigned long)topPlacesArray.count);
            if (completionBlock) {
                completionBlock(true,topPlacesArray);
            }
        }else{
            NSLog(@"Error fetching top places, %@",[FlickrFetcher URLforTopPlaces]);
        }
    });
}

+(void) getPhotoListForFlickrPlace:(FlickerPlace *)flickrPlace withCompletionBlock:(void (^)(BOOL success, NSArray *result))completionBack{
    NSLog(@"Not yet implemented.[2]");
}

+(void) getPhoto:(FlickerPhoto *)photo withCompletionBlock:(void (^)(BOOL success, NSData *result))completionBack{
    NSLog(@"Not yet implemented.[3]");
}
@end