//
//  TPHistory.m
//  top-places
//
//  Created by Amr Lotfy on 10/3/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPHistory.h"

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

+(void) addImage:(NSDictionary *)imageInfo{
    if (imageInfo) {
        [[[self sharedInstance] photoHistory] insertObject:imageInfo atIndex:0];
        while ([[[self sharedInstance] photoHistory] count] > MAX_HISTORY_ENTRIES_COUNT) {
            [[[self sharedInstance] photoHistory] removeObjectAtIndex:MAX_HISTORY_ENTRIES_COUNT];
        }
        
    }
}

-(NSMutableArray *) photoHistory{
    if (!_photoHistory) {
        _photoHistory= [@[] mutableCopy];
    }
    return _photoHistory;
}

@end
