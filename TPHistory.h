//
//  TPHistory.h
//  top-places
//
//  Created by Amr Lotfy on 10/3/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TPHistory : NSObject

@property (strong,nonatomic) NSMutableArray * photoHistory;

+(void) addImage:(NSDictionary *)imageInfo;

@end
