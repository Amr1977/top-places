//
//  TPTopPlacesTableViewController.h
//  top-places
//
//  Created by Amr Lotfy on 9/30/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TPTopPlacesTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate >
@property (strong, nonatomic) NSArray * topPlaces;
@property (strong,nonatomic) NSDictionary * countryHashedPlaces;
@end
