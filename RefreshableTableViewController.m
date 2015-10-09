//
//  RefreshableTableViewController.m
//  top-places
//
//  Created by Amr Lotfy on 10/1/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "RefreshableTableViewController.h"

@implementation RefreshableTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setRefreshControl];
    [self loadData];
}

- (void)setRefreshControl {
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [self.tableView addSubview:refreshControl];
    self.refreshControl = refreshControl;
    [self.refreshControl addTarget:self action:@selector(loadData) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - Table view data source

-(void) loadData{
    NSLog(@">>>>>>>>> Hit empty implementation ! [%@] method: [%@]",self.class,NSStringFromSelector(_cmd));
}



@end
