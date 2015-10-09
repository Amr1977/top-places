//
//  TPTabBarViewController.m
//  top-places
//
//  Created by Amr Lotfy on 9/29/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPTabBarViewController.h"
#import "TPDataLoader.h"
#import "TPHistory.h"

@implementation TPTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [TPHistory cleanHistory] ;
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
