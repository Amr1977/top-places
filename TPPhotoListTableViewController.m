//
//  TPPhotoListTableViewController.m
//  top-places
//
//  Created by Amr Lotfy on 10/1/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPPhotoListTableViewController.h"
#import "FlickrFetcher.h"
#import "TPDataLoader.h"
#import "TPHistory.h"
#import "TPPhotoDetailsViewController.h"

@interface TPPhotoListTableViewController ()
@property (strong,nonatomic) NSArray * photoList;
@end

@implementation TPPhotoListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //NSLog(@"Recieved place ID: %@",self.placeId);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void) loadData{
    [self.refreshControl beginRefreshing];
    __weak TPPhotoListTableViewController * weakSelf=self;
    void (^block)(BOOL success, NSArray *result) = ^(BOOL success, NSArray *result) {
        if (success) {
            weakSelf.photoList=result;
            NSLog(@"Recieved photo list: %@",self.photoList);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [weakSelf.refreshControl endRefreshing];
        });
    };
    
    [TPDataLoader getPhotoListForFlickrPlace:self.placeId withCompletionBlock:block];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.photoList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"photo_cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    NSDictionary * photoDictionary=self.photoList[indexPath.row];
    //[TPHistory addImage:photoDictionary];
    NSString * photoTitle= photoDictionary[FLICKR_PHOTO_TITLE];
    NSString * photoSubTitle= photoDictionary[FLICKR_PHOTO_DESCRIPTION];
    
    if (!photoSubTitle) {
        photoSubTitle=@"UNKNOWN";
    }
    if (!photoTitle) {
        photoTitle=photoSubTitle;
    }
    
    
    
    // Configure the cell...
    cell.textLabel.text = photoTitle;
    cell.detailTextLabel.text = photoSubTitle;
    NSLog(@"cell title: [%@], subtitle:[%@]",photoTitle,photoSubTitle);
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"photo_details"]) {
        NSLog(@"Navigating to photo viewer.");
        TPPhotoDetailsViewController * photoView= [segue destinationViewController];
        NSIndexPath *selectedIndexPath = [self.tableView indexPathForSelectedRow];
        photoView.photoInfoDictionary = [self.photoList[selectedIndexPath.row] copy];
    }
    
}

#define PHOTO_DETAILS_SEGUE_IDENTIFIER @"photo_details"
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self performSegueWithIdentifier:PHOTO_DETAILS_SEGUE_IDENTIFIER sender:nil];
}


@end
