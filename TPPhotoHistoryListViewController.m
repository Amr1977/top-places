//
//  TPPhotoHistoryListViewController.m
//  top-places
//
//  Created by Amr Lotfy on 10/4/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPPhotoHistoryListViewController.h"
#import "TPPhotoDetailsViewController.h"
#import "TPHistory.h"

@interface TPPhotoHistoryListViewController ()

@end

@implementation TPPhotoHistoryListViewController

-(void) loadData{
    NSMutableArray * photoListFromUserDefaults= [@[] mutableCopy];
    for (NSString * photoId in [TPHistory sharedInstance].photosIDsArray) {
        NSDictionary * photoHistoryEntryDictionary=[TPHistory sharedInstance].photosHistory[photoId];
        if (photoHistoryEntryDictionary) {
            [photoListFromUserDefaults addObject:photoHistoryEntryDictionary[HISTORY_ENTRY_IMAGE_INFO_KEY]];
        }
    }
    self.photoList = [photoListFromUserDefaults mutableCopy];
    [self.tableView reloadData];
    [self.refreshControl endRefreshing];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"history_photo_details"]) {
        NSLog(@"Navigating to photo viewer.");
        TPPhotoDetailsViewController * photoView= [segue destinationViewController];
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        photoView.photoInfoDictionary = [self.photoList[selectedIndexPath.row] copy];
    }
    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:@"history_photo_details" sender:nil];
}

-(void) viewWillAppear:(BOOL)animated{
    NSLog(@"[%@][%@]",NSStringFromClass([self class]),NSStringFromSelector(_cmd));
    [self loadData];
    
}

@end
