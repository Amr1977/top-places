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
@property (strong, nonatomic) UIImageView *photoImageView;

@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong,nonatomic) NSData * photoData;
@property (strong,nonatomic) UIImage * image;



@end

@implementation TPPhotoDetailsViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title=self.photoInfoDictionary[@"title"];
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    fullScreenRect.origin.y=self.navigationController.navigationBar.frame.size.height;
    fullScreenRect.size.height-=self.tabBarController.tabBar.frame.size.height;

    self.scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    self.scrollView.backgroundColor=[UIColor blackColor];
    self.scrollView.contentSize=fullScreenRect.size;
    
    self.photoImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    self.photoImageView.backgroundColor= [UIColor greenColor];
   
    
    self.activityIndicator= [[UIActivityIndicatorView alloc] init];
    
    [self.scrollView addSubview:self.photoImageView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.activityIndicator];
    self.photoImageView.center=self.scrollView.center;
    self.activityIndicator.center=self.scrollView.center;
    self.activityIndicator.activityIndicatorViewStyle= UIActivityIndicatorViewStyleWhiteLarge;
    self.scrollView.delegate=self;
    self.scrollView.minimumZoomScale=0.5;
    self.scrollView.maximumZoomScale=6.0;
    
    [self loadData];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    fullScreenRect.origin.y=self.navigationController.navigationBar.frame.size.height;
    fullScreenRect.size.height-=self.tabBarController.tabBar.frame.size.height;
    
    self.scrollView.frame=fullScreenRect;
   
}

-(void) setImage:(UIImage *)image{
    _image = image;
    
    NSLog(@"image dimensions: [w: %.2f, h: %.2f]",self.image.size.width,self.image.size.height);
    
    [self adjustFrameSize];
    
    [self.activityIndicator stopAnimating];
}

-(void) setPhotoData:(NSData *)data{
    _photoData=data;
    NSLog(@"image size: [%.2f]KB",(float)data.length/1024.0f);
    [TPHistory addImageData:data withInfo:self.photoInfoDictionary];
    [self setImage: [UIImage imageWithData:data]];
}


-(void) adjustFrameSize{
    NSLog(@"adjusting frames ...");
    //adjust photo image view frame to the size of the loaded image
    CGSize imageSize=self.image.size;
    CGRect photoImageViewFrame =  CGRectMake(0, 0, imageSize.width, imageSize.height);
    self.photoImageView.frame=photoImageViewFrame;
    self.photoImageView.image=self.image;
    
    //adjust scroll view content size to be equal to photo image view frame size
    self.scrollView.contentSize=imageSize;
    self.scrollView.maximumZoomScale=3;
    self.scrollView.minimumZoomScale=0.1;
    
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    fullScreenRect.origin.y=self.navigationController.navigationBar.frame.size.height;
    fullScreenRect.size.height-=self.tabBarController.tabBar.frame.size.height;
    
    CGFloat verticalRatio= fullScreenRect.size.width / self.image.size.width;
    CGFloat horizontalRatio = fullScreenRect.size.height / self.image.size.height;
    self.scrollView.zoomScale=MIN(verticalRatio, horizontalRatio);//to fit in scroll view frame.
    
    NSLog(@"adjusting frames ... Done.");
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.photoImageView;
}

/**
 Starts fetching image data of currently selected photo info dictionary.
 */
-(void)loadData{
    __weak TPPhotoDetailsViewController * weakSelf=self;
    if (self.photoInfoDictionary) {
        NSLog(@"received image info dictionary: %@", self.photoInfoDictionary);
        //start animating activity indicator
        [self.activityIndicator startAnimating];
        NSString * photoId=self.photoInfoDictionary[FLICKR_PHOTO_ID];
        if (!([self loadHistoryEntryFileImageWithPhotoId:photoId])) {
            NSLog(@"Attempting to download image....");
            //define download completion block
            void (^block)(BOOL success, NSData * photoData) = ^(BOOL success, NSData * photoData){
                if (success) {
                    [weakSelf setPhotoData:photoData];
                    NSLog(@"Download image....Finished");
                }else{
                    NSLog(@"Download image....error");
                    [weakSelf.navigationController popViewControllerAnimated:YES];
                }
            };
            //start fetch image data
            [TPDataLoader getPhoto:self.photoInfoDictionary withCompletionBlock:block];
        }
    }
}

-(BOOL) loadHistoryEntryFileImageWithPhotoId:(NSString *) photoId{
    BOOL result=NO;
    //load from file path stored in the history structure
    NSString * filePath=[TPHistory sharedInstance].photosHistory[photoId][HISTORY_ENTRY_IMAGE_PATH_KEY];
    if (filePath) {
        NSLog(@"starting to load image from filePath: [%@]",  filePath);
        NSData * dataFromFile = [NSData dataWithContentsOfFile:filePath];
        if (dataFromFile) {
            NSLog(@"Loaded image successfully.");
            [self setImage:[UIImage imageWithData:dataFromFile]];
            result=YES;
        }
    }else{
        NSLog(@"No such file in history filePath: [%@]",  filePath);
    }
    return result;
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
