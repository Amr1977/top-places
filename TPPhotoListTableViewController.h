//
//  TPPhotoListTableViewController.h
//  top-places
//
//  Created by Amr Lotfy on 10/1/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RefreshableTableViewController.h"

@interface TPPhotoListTableViewController : RefreshableTableViewController

@property (strong,nonatomic) NSString *placeId;
@property (strong,nonatomic) NSArray * photoList;

@end
