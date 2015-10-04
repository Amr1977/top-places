//
//  TPPhotoDetailsViewController.m
//  top-places
//
//  Created by Amr Lotfy on 10/3/15.
//  Copyright (c) 2015 Amr Lotfy. All rights reserved.
//

#import "TPPhotoDetailsViewController.h"
#import "TPDataLoader.h"
#import "TPHistory.h"

@interface TPPhotoDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong,nonatomic) NSData * photoData;

@end

@implementation TPPhotoDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    //TODO: adjust activity indicator size and position
    
    
    [self loadData];
    
}

/**
 Fetches and displays the image data of currently selected photo info dictionary.
 */
-(void)loadData{
    __weak TPPhotoDetailsViewController * weakSelf=self;
    if (self.photoInfoDictionary) {
        NSLog(@"[%@] received image info dicitonary: %@",NSStringFromSelector(_cmd), self.photoInfoDictionary);
        //start animating activity indicator
        [self.activityIndicator startAnimating];
        
        void (^block)(BOOL success, NSData * photoData) = ^(BOOL success, NSData * photoData){
            if (success) {
                
                self.photoImageView.image = [UIImage imageWithData:photoData];
                [TPHistory addUIImage:photoData withInfo:self.photoInfoDictionary];
            }
            [weakSelf.activityIndicator stopAnimating];
        };
        
        //fetch image data
        [TPDataLoader getPhoto:self.photoInfoDictionary withCompletionBlock:block];
        
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
