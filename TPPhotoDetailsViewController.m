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
    
    //TODO: adjust activity indicator size and position
    [self loadData];
    
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];

    self.scrollView=[[UIScrollView alloc] initWithFrame:fullScreenRect];
    self.scrollView.backgroundColor=[UIColor blackColor];
    self.scrollView.contentSize=CGSizeMake(1024, 1024);
    self.activityIndicator.center=self.scrollView.center;
    
    self.photoImageView=[[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    self.photoImageView.backgroundColor= [UIColor whiteColor];
    self.photoImageView.center=self.scrollView.center;
    
    self.activityIndicator= [[UIActivityIndicatorView alloc] init];
    
    
    
    [self.scrollView addSubview:self.photoImageView];
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.activityIndicator];
    
    //UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPinched:)];
    //UIPanGestureRecognizer *panGestureRecognizer=[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(scrollViewPan:)];
    
    //[self.scrollView addGestureRecognizer:pinchGestureRecognizer];
    //[self.scrollView addGestureRecognizer:panGestureRecognizer];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    CGRect fullScreenRect=[[UIScreen mainScreen] applicationFrame];
    self.scrollView.frame=fullScreenRect;
    
}

-(void) setImage:(UIImage *)image{
    _image =image;
    
    NSLog(@"image dimensions: [w: %.2f, h: .2f]",self.image.size.width,self.image.size.height);
    
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
    
    
    //CGRect scrollViewFrame = self.scrollView.frame;
    //CGFloat scaleWidth = scrollViewFrame.size.width / self.scrollView.contentSize.width;
    //CGFloat scaleHeight = scrollViewFrame.size.height / self.scrollView.contentSize.height;
    //CGFloat minScale = MIN(scaleWidth, scaleHeight);
   //self.scrollView.minimumZoomScale = minScale;
    
    // 5
    //self.scrollView.maximumZoomScale = 1.0f;
    //self.scrollView.zoomScale = minScale;
    //[self centerScrollViewContents];

}

- (void)centerScrollViewContents {
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect contentsFrame = self.photoImageView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    
    self.photoImageView.frame = contentsFrame;
}

-(void) scrollViewPinched:(UIPinchGestureRecognizer *)recognizer{
    NSLog(@"pinch gesture detected.");
    //self.photoImageView.contentMode = UIViewContentModeCenter;
    //recognizer.view.transform = CGAffineTransformScale(recognizer.view.transform, recognizer.scale, recognizer.scale);
    //recognizer.scale = 1;
    
    NSLog(@"scale: [%.2f]scroll View frame: [%.2f,%.2f], image view size:[%.2f,%.2f]",recognizer.scale,self.scrollView.frame.size.width,self.scrollView.frame.size.height,self.photoImageView.frame.size.width,self.photoImageView.frame.size.height);
}

-(void) scrollViewPan:(UIPanGestureRecognizer *)recognizer{
    NSLog(@"pan gesture detected.");
    //self.photoImageView.contentMode = UIViewContentModeCenter;
    CGPoint translation = [recognizer translationInView:self.view];
    recognizer.view.center = CGPointMake(recognizer.view.center.x + translation.x,
                                         recognizer.view.center.y + translation.y);
    [recognizer setTranslation:CGPointMake(0, 0) inView:self.view];
    //NSLog(@"scroll View frame: [%@], image view frame:[%@]",self.scrollView.frame,self.photoImageView.frame);
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

            //define download completion block
            void (^block)(BOOL success, NSData * photoData) = ^(BOOL success, NSData * photoData){
                if (success) {
                    [weakSelf setPhotoData:photoData];
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
    NSLog(@"starting to load image from filePath: [%@]",  filePath);
    UIImage * imageFromFile=[UIImage imageWithContentsOfFile:filePath];
    if (imageFromFile) {
        self.photoImageView.image  = imageFromFile;
        //self.photoImageView.frame = (CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=imageFromFile.size};
        self.photoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.scrollView.contentSize = imageFromFile.size;
        NSLog(@"image loaded.");
        [self adjustFrameSize];
        [self.activityIndicator stopAnimating];
        result=YES;
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
