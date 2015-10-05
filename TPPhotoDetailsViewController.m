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
#import "FlickrFetcher.h"

@interface TPPhotoDetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (strong,nonatomic) NSData * photoData;

@end

@implementation TPPhotoDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=self.photoInfoDictionary[@"title"];
    
    //TODO: adjust activity indicator size and position
    [self loadData];
    
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPinched:)];
    UIPanGestureRecognizer *panGestureRecognizer=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPan:)];
    
    [self.scrollView addGestureRecognizer:pinchGestureRecognizer];
    [self.scrollView addGestureRecognizer:panGestureRecognizer];
}

-(void) scrollViewPinched:(UIPinchGestureRecognizer *)recognizer{
    NSLog(@"pinch gesture detected.");
    recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    recognizer.scale = 1;
}

-(void) scrollViewPan:(UIPanGestureRecognizer *)recognizer{
    NSLog(@"pan gesture detected.");
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
}

/**
 Fetches and displays the image data of currently selected photo info dictionary.
 */
-(void)loadData{
    __weak TPPhotoDetailsViewController * weakSelf=self;
    if (self.photoInfoDictionary) {
        //TODO: if exsts in history don't download and use local copy
        NSLog(@"received image info dictionary: %@", self.photoInfoDictionary);
        //start animating activity indicator
        [self.activityIndicator startAnimating];
        NSString * photoId=self.photoInfoDictionary[FLICKR_PHOTO_ID];
        if ([TPHistory photoExistsInHistory:photoId]) {
            //load from file path stored in the history structure
            NSString * filePath=[TPHistory sharedInstance].photosHistory[photoId][HISTORY_ENTRY_IMAGE_PATH_KEY];
            NSLog(@"starting to load image from filePath: [%@]",  filePath);
            UIImage * imageFromFile=[UIImage imageWithContentsOfFile:filePath];
            if (imageFromFile) {
                self.photoImageView.image  = imageFromFile;
                self.photoImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=imageFromFile.size};
                self.scrollView.contentSize = imageFromFile.size;
                NSLog(@"image loaded.");
            }else{
                NSLog(@"!!!!!!!!!!!!!file not found.[%@]", filePath);
                //TODO: delete history entry of the deleted file.
                [[TPHistory sharedInstance].photosIDsArray removeObject:photoId];
                [[TPHistory sharedInstance].photosHistory removeObjectForKey:photoId];
                [TPHistory updateUserDefaults];
                [self.navigationController popViewControllerAnimated:YES];
            }
            
            [self.activityIndicator stopAnimating];
        }else{
            void (^block)(BOOL success, NSData * photoData) = ^(BOOL success, NSData * photoData){
                if (success) {
                    self.photoImageView.image = [UIImage imageWithData:photoData];
                    [TPHistory addImageData:photoData withInfo:self.photoInfoDictionary];
                }
                [weakSelf.activityIndicator stopAnimating];
            };
            
            //fetch image data
            [TPDataLoader getPhoto:self.photoInfoDictionary withCompletionBlock:block];
        }
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
