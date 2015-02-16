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
                                                                action:@selector(handleTap:)];
    self.imageViewTap.numberOfTouchesRequired = 1;
    self.imageViewTap.numberOfTapsRequired = 1;

    [cell addGestureRecognizer:self.imageViewTap];
    // NOTE: Must set interaction true so that the gesture can be triggered. Dont have to have selector on the filter ImageView
    cell.userInteractionEnabled = YES;
}

- (void)handleTap:(UIGestureRecognizer *)sender {
    NSLog(@"Recognized tap");
    FLAnnotationTableViewCell *targetCell = (FLAnnotationTableViewCell *)sender.view;
    CGPoint annotationPoint = [sender locationInView:targetCell.selectedImageViewBackground];

    NSLog(@"handleTap X Point %f, Y Point %f", annotationPoint.x, annotationPoint.y);
    [targetCell.photo setAnnotationPoint:annotationPoint];

    [self setFlameIconOnCell:targetCell];
}

-(void)setFlameIconOnCell:(FLAnnotationTableViewCell *)targetCell {
    UIImageView *imageView = targetCell.selectedImageViewBackground;
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:targetCell.originalImage];

    // Flame Image
    UIImage *overlayImage = [self createFlame:targetCell.frame.size atTouchPoint:targetCell.photo.annotationPoint];
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
    // NOTE: Input size is changing!!
    NSLog(@"Input Size %f %f",inputSize.height, inputSize.width);
    NSLog(@"Touch Point %f %f",touchPoint.x, touchPoint.y);
    // Redefinition help?
    inputSize = CGSizeMake(320,320);
    // Load the image
    UIImage * heartIcon = [UIImage imageNamed:@"heartIcon.png"];

//    CGFloat heartIconAspectRatio = heartIcon.size.width / heartIcon.size.height;

//    NSInteger targetFlameyWidth = inputSize.width * 0.2;
//    CGSize heartSize = CGSizeMake(inputSize.width, targetFlameyWidth / heartIconAspectRatio);

    // TODO: This is an incorrect way to adjust for touch recognition offset

    // Build the new bounding box for the icon
    CGFloat reduction = heartIcon.size.width/2;
    CGPoint newPoint = CGPointMake(touchPoint.x-reduction, touchPoint.y-reduction);

    CGRect heartRect = {newPoint, heartIcon.size};

    NSLog(@"Heart rect %f %f %f %f", heartRect.origin.x,heartRect.origin.y,heartRect.size.width, heartRect.size.height);

    UIGraphicsBeginImageContext(inputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();



    CGRect inputRect = {CGPointZero, inputSize};
    CGContextClearRect(context, inputRect);

    CGAffineTransform flip = CGAffineTransformMakeScale(1.0, -1.0);
    CGAffineTransform flipThenShift = CGAffineTransformTranslate(flip,0,-inputSize.height);
    CGContextConcatCTM(context, flipThenShift);
    CGRect transformedGhostRect = CGRectApplyAffineTransform(heartRect, flipThenShift);

    CGContextDrawImage(context, transformedGhostRect, [heartIcon CGImage]);

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
    [_selectedPhotosTable setSeparatorColor:[UIColor clearColor]];
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
        cell.photo = photo;

        [cell.selectedImageViewBackground sd_setImageWithURL:[NSURL URLWithString:photo.URL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

            cell.originalImage = image;
            [cell.contentView setUserInteractionEnabled:YES];

            NSLog(@"BACKGROUND BEFORE %f %f",cell.selectedImageViewBackground.frame.size.height, cell.selectedImageViewBackground.frame.size.width);
            cell.selectedImageViewBackground.transform = CGAffineTransformMakeRotation(M_PI_2);
            NSLog(@"BACKGROUND AFTER %f %f",cell.selectedImageViewBackground.frame.size.height, cell.selectedImageViewBackground.frame.size.width);
            // Do I need to reset the frame to retain its size?

            // CGPoint is scalar so comparison to nil wont work - this does :)
            if (!CGPointEqualToPoint(photo.annotationPoint, CGPointZero)) {
                CGPoint point = photo.annotationPoint;
                NSLog(@"handleTap X Point %f, Y Point %f", point.x, point.y);

                [self setFlameIconOnCell:cell];
            }

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
