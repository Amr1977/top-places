//
//  RefreshableTableViewController.h
//  top-places
//
//  Created by Amr Lotfy on 10/1/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RefreshableTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong,nonatomic) UIRefreshControl * refreshControl;

-(void) setRefreshControl;
-(void) loadData;

@end
