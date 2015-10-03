//
//  TPHistory.h
//  top-places
//
//  Created by Amr Lotfy on 10/3/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface TPHistory : NSObject

@property (strong,nonatomic) NSMutableDictionary * photosHistory;

@property (strong,nonatomic) NSMutableArray * photosIDsArray;


+(void) addUIImage:(UIImage *) image withInfo:(NSDictionary *)imageInfo;

+(instancetype) sharedInstance;

@end
