//
//  FLImageAnnotationViewController.m
//  Flamey
//
//  Created by Shane Rogers on 2/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLImageAnnotationViewController.h"

// Components
#import "FLFacebookUploadModalViewController.h"
#import "FLAnnotationTableViewCell.h"

// Pods
#import <SDWebImage/UIImageView+WebCache.h>

// Data Layer
#import "FLPhotoStore.h"
#import "FLProcessedImagesStore.h"
#import "FLAnnotationStore.h"

// Pods
#import "GPUImageLookupFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageAlphaBlendFilter.h"

@interface FLImageAnnotationViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *imageViewTap;
@property (strong, nonatomic) UITableView *selectedPhotosTable;

@end

static NSString * const kAnnotationTableViewCellIdentifier = @"FLAnnotationTableViewCell";

@implementation FLImageAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self renderLateralTable];
    [self updateAnnotationStore];
}

- (void)updateAnnotationStore {
    // Update the annotation store with any recently selected photos
    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];
    FLPhotoStore *photoStore = [FLPhotoStore sharedStore];

    for (FLPhoto* photo in photoStore.allPhotos) {
        [annotationStore addUniquePhoto:photo];
    }
}

- (void)addTapGestureRecogniserToCell:(FLAnnotationTableViewCell *)cell {
    NSLog(@"SETTING");
    self.imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(setFlameIcon:)];
    self.imageViewTap.numberOfTouchesRequired = 1;
    self.imageViewTap.numberOfTapsRequired = 1;

    [cell addGestureRecognizer:self.imageViewTap];
    // NOTE: Must set interaction true so that the gesture can be triggered. Dont have to have selector on the filter ImageView
    cell.userInteractionEnabled = YES;
}

- (void)setFlameIcon:(UIGestureRecognizer *)sender {
    NSLog(@"Recognized tap");
    FLAnnotationTableViewCell *targetCell = (FLAnnotationTableViewCell *)sender.view;

    UIImageView *imageView = targetCell.selectedImageViewBackground;

    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:targetCell.facebookImage];

    // Flame Image
    CGPoint point = [sender locationInView:targetCell.selectedImageViewBackground];
    UIImage *overlayImage = [self createFlame:imageView.frame.size atTouchPoint:point];
    GPUImagePicture *flameyGPUImage = [[GPUImagePicture alloc] initWithImage:overlayImage];

    // 2. Set up the filter chain
    GPUImageAlphaBlendFilter * alphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    alphaBlendFilter.mix = 1.0;

    [inputGPUImage addTarget:alphaBlendFilter atTextureLocation:0];
    [flameyGPUImage addTarget:alphaBlendFilter atTextureLocation:1];

    [alphaBlendFilter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    [flameyGPUImage processImage];

    UIImage *processedImage = [alphaBlendFilter imageFromCurrentFramebuffer];

    FLPhoto *processedPhoto = [[FLPhoto alloc] init];
    processedPhoto.image = processedImage;
    FLProcessedImagesStore *processedImagesStore = [FLProcessedImagesStore sharedStore];
    [processedImagesStore addUniquePhoto:processedPhoto];

    [imageView setImage:processedImage];
}

- (UIImage *)createFlame:(CGSize)inputSize atTouchPoint:(CGPoint)touchPoint {
    UIImage * ghostImage = [UIImage imageNamed:@"ghost.png"];

    CGFloat flameyIconAspectRatio = ghostImage.size.width / ghostImage.size.height;

    NSInteger targetFlameyWidth = inputSize.width * 0.2;
    CGSize flameSize = CGSizeMake(targetFlameyWidth, targetFlameyWidth / flameyIconAspectRatio);

    // TODO: This is an incorrect way to adjust for touch recognition offset
    CGPoint newPoint = CGPointMake(touchPoint.x * 0.85, touchPoint.y * 0.85);

    CGRect flameRect = {newPoint, flameSize};

    UIGraphicsBeginImageContext(inputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect inputRect = {CGPointZero, inputSize};
    CGContextClearRect(context, inputRect);

    CGAffineTransform flip = CGAffineTransformMakeScale(1.0, -1.0);
    CGAffineTransform flipThenShift = CGAffineTransformTranslate(flip,0,-inputSize.height);
    CGContextConcatCTM(context, flipThenShift);
    CGRect transformedGhostRect = CGRectApplyAffineTransform(flameRect, flipThenShift);

    CGContextDrawImage(context, transformedGhostRect, [ghostImage CGImage]);

    UIImage *flameyIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return flameyIcon;
}

- (void)renderLateralTable {
    CGRect tableRect = CGRectMake(0,0, self.view.frame.size.width, self.view.frame.size.width);
    _selectedPhotosTable = [[UITableView alloc] initWithFrame:tableRect style:UITableViewStylePlain];;
    [self.tableContainer addSubview:_selectedPhotosTable];

    CGAffineTransform rotate = CGAffineTransformMakeRotation(-M_PI_2);
    [_selectedPhotosTable setTransform:rotate];

    // VIP: Must set the frame again on the table after rotation
    [_selectedPhotosTable setFrame:tableRect];

    [_selectedPhotosTable registerClass:[UITableViewCell class] forCellReuseIdentifier:kAnnotationTableViewCellIdentifier];
    _selectedPhotosTable.delegate = self;
    _selectedPhotosTable.dataSource = self;
    _selectedPhotosTable.alwaysBounceVertical = NO;
    _selectedPhotosTable.scrollEnabled = YES;
    _selectedPhotosTable.showsVerticalScrollIndicator = NO;
    [_selectedPhotosTable setSeparatorColor:[UIColor blackColor]];

//    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(decrementTable:)];
//    leftSwipe.direction = UISwipeGestureRecognizerDirectionDown;
//    leftSwipe.numberOfTouchesRequired = 1;
//    [_selectedPhotosTable addGestureRecognizer:leftSwipe];
//
//    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(incrementTable:)];
//    rightSwipe.direction = UISwipeGestureRecognizerDirectionUp;
//    rightSwipe.numberOfTouchesRequired = 1;
//    [_selectedPhotosTable addGestureRecognizer:rightSwipe];
}

- (void)decrementTable:(UIGestureRecognizer *)gr {
    NSLog(@"Decrement Table");
}

- (void)incrementTable:(UIGestureRecognizer *)gr {
    NSLog(@"Increment Table");
}

#pragma UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];

    return [[annotationStore allPhotos] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];

    // Load the custom xib
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kAnnotationTableViewCellIdentifier owner:nil options:nil];
    FLAnnotationTableViewCell *cell = [nibContents lastObject];

    if([tableView isEqual:_selectedPhotosTable]) {
        FLPhoto *photo = [[annotationStore allPhotos] objectAtIndex:[indexPath row]];

        [cell.selectedImageViewBackground sd_setImageWithURL:[NSURL URLWithString:photo.URL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

            cell.facebookImage = image;

            [cell.contentView setUserInteractionEnabled:YES];
            cell.selectedImageViewBackground.transform = CGAffineTransformMakeRotation(M_PI_2);
            [self addTapGestureRecogniserToCell:cell];
        }];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
