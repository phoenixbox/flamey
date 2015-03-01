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
#import <MDCSwipeToChoose/MDCSwipeToChoose.h>

// Data Layer
#import "FLSelectedPhotoStore.h"
#import "FLProcessedImagesStore.h"
#import "FLAnnotationStore.h"

// Pods
#import "GPUImageLookupFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageAlphaBlendFilter.h"

@interface FLImageAnnotationViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *imageViewTap;
@property (nonatomic, strong) UISwipeGestureRecognizer *cellRemoveSwipe;
@property (strong, nonatomic) UITableView *selectedPhotosTable;
@property (assign, nonatomic) BOOL DEVELOPMENT_ENV;

@end

static NSString * const kAnnotationTableViewCellIdentifier = @"FLAnnotationTableViewCell";
static NSString * const kAnnotationTableEmptyMessageView = @"FLAnnotationTableEmptyMessageView";

@implementation FLImageAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _DEVELOPMENT_ENV = false;

    [self updateUploadButtonState];

    [self renderLateralTable];


    // TODO: Update filters flow
    [_addFiltersButton setHidden:YES];
    [self updateAnnotationStore];
}

- (void)updateUploadButtonState {
    NSUInteger count = [[FLProcessedImagesStore sharedStore].photos count];

    if ( count == 0) {
        [self setUploadInactive];
    } else {
        [_uploadButton setUserInteractionEnabled:YES];
        [_uploadButton setBackgroundColor:[UIColor greenColor]];
        [_uploadButton setAlpha:0.5];
        NSString *buttonTitle = [NSString stringWithFormat:@"No Photos Marked %lu", (unsigned long)count];
        [_uploadButton setTitle:buttonTitle forState:UIControlStateNormal];
    }
}

- (void)setUploadInactive {
    [_uploadButton setUserInteractionEnabled:NO];
    [_uploadButton setBackgroundColor:[UIColor grayColor]];
    [_uploadButton setAlpha:0.5];
    [_uploadButton setTitle:@"No Photos Marked" forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated {
    if(!_DEVELOPMENT_ENV) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_targetRow inSection:0];

        [_selectedPhotosTable scrollToRowAtIndexPath:indexPath
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
    }
}

- (void)updateAnnotationStore {
    // Update the annotation store with any recently selected photos
    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];
    FLSelectedPhotoStore *photoStore = [FLSelectedPhotoStore sharedStore];

    for (FLPhoto* photo in photoStore.allPhotos) {
        [annotationStore addUniquePhoto:photo];
    }
}

//- (void)addDeleteSwipeGestureRecogniserToCell:(FLAnnotationTableViewCell *)cell {
//    /* Instantiate our object */
//    self.cellRemoveSwipe = [[UISwipeGestureRecognizer alloc]
//                                   initWithTarget:self
//                                   action:@selector(handleSwipe:)];
//    /* Swipes that are performed from right to
//     left are to be detected */
//    self.cellRemoveSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
//    /* Just one finger needed */
//    self.cellRemoveSwipe.numberOfTouchesRequired = 1; /* Add it to the view */
//    [cell addGestureRecognizer:self.cellRemoveSwipe];
//
//    // NOTE: Must set interaction true so that the gesture can be triggered
//    // Dont have to have selector on the filter ImageView
//    cell.userInteractionEnabled = YES;
//}
//
//
//- (void)handleSwipe:(UIGestureRecognizer *)sender {
//    FLAnnotationTableViewCell *targetCell = (FLAnnotationTableViewCell *)sender.view;
//    CGPoint annotationPoint = [sender locationInView:targetCell.selectedImageViewBackground];
//
//    NSLog(@"handleTap X Point %f, Y Point %f", annotationPoint.x, annotationPoint.y);
//    [targetCell.photo setAnnotationPoint:annotationPoint];
//
//    [self setFlameIconOnCell:targetCell];
//}

- (void)addTapGestureRecogniserToCell:(FLAnnotationTableViewCell *)cell {
    self.imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(handleTap:)];
    self.imageViewTap.numberOfTouchesRequired = 1;
    self.imageViewTap.numberOfTapsRequired = 1;

    [cell addGestureRecognizer:self.imageViewTap];
    // NOTE: Must set interaction true so that the gesture can be triggered
    // Dont have to have selector on the filter ImageView
    cell.userInteractionEnabled = YES;
}

- (void)handleTap:(UIGestureRecognizer *)sender {
    FLAnnotationTableViewCell *targetCell = (FLAnnotationTableViewCell *)sender.view;
    CGPoint annotationPoint = [sender locationInView:targetCell.selectedImageViewBackground];

    NSLog(@"handleTap X Point %f, Y Point %f", annotationPoint.x, annotationPoint.y);
    [targetCell.photo setAnnotationPoint:annotationPoint];

    [self setFlameIconOnCell:targetCell];

    [self updateUploadButtonState];
}

-(void)setFlameIconOnCell:(FLAnnotationTableViewCell *)targetCell {
    UIImageView *imageView = targetCell.selectedImageViewBackground;
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:targetCell.originalImage];

    // Flame Image
    // NOTE: Input size is mutating on table view cell dequeue - so shim with fixed viewport width size
//    CGSize imageAspect = [self imageSizeAfterAspectFit:targetCell.selectedImageViewBackground];

    CGSize imageOverlaySize = CGSizeMake(self.view.frame.size.width, self.view.frame.size.width);
    UIImage *overlayImage = [self createFlameForSize:imageOverlaySize atTouchPoint:targetCell.photo.annotationPoint];
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

//    annotate the new photo model with the id related to the target cell
    FLPhoto *processedPhoto = [[FLPhoto alloc] init];
//    NSLog(@"Photo ID: %lu", (unsigned long)targetCell.photo.id);
    processedPhoto.id = targetCell.photo.id;
    processedPhoto.image = processedImage;
    FLProcessedImagesStore *processedImagesStore = [FLProcessedImagesStore sharedStore];
    [processedImagesStore addUniquePhoto:processedPhoto];

    [imageView setImage:processedImage];
}

-(CGSize)imageSizeAfterAspectFit:(UIImageView*)imgview{
    float newwidth;
    float newheight;

    UIImage *image=imgview.image;

    if (image.size.height>=image.size.width){
        newheight=imgview.frame.size.height;
        newwidth=(image.size.width/image.size.height)*newheight;

        if(newwidth>imgview.frame.size.width){
            float diff=imgview.frame.size.width-newwidth;
            newheight=newheight+diff/newheight*newheight;
            newwidth=imgview.frame.size.width;
        }

    }
    else{
        newwidth=imgview.frame.size.width;
        newheight=(image.size.height/image.size.width)*newwidth;

        if(newheight>imgview.frame.size.height){
            float diff=imgview.frame.size.height-newheight;
            newwidth=newwidth+diff/newwidth*newwidth;
            newheight=imgview.frame.size.height;
        }
    }

    NSLog(@"image after aspect fit: width=%f height=%f",newwidth,newheight);


    //adapt UIImageView size to image size
    //imgview.frame=CGRectMake(imgview.frame.origin.x+(imgview.frame.size.width-newwidth)/2,imgview.frame.origin.y+(imgview.frame.size.height-newheight)/2,newwidth,newheight);
    
    return CGSizeMake(newwidth, newheight);
}

- (UIImage *)createFlameForSize:(CGSize)overlaySize atTouchPoint:(CGPoint)touchPoint {
//    NSLog(@"Input Size %f %f",overlaySize.height, overlaySize.width);
//    NSLog(@"Touch Point %f %f",touchPoint.x, touchPoint.y);
//  Load the image
    UIImage * heartIcon = [UIImage imageNamed:@"heartIcon.png"];

//  CGFloat heartIconAspectRatio = heartIcon.size.width / heartIcon.size.height;

//  NSInteger targetFlameyWidth = inputSize.width * 0.2;
//  CGSize heartSize = CGSizeMake(inputSize.width, targetFlameyWidth / heartIconAspectRatio);

//  TODO: This is an incorrect way to adjust for touch recognition offset

    // Build the new bounding box for the icon
    CGFloat reduction = heartIcon.size.width/2;
    CGPoint newPoint = CGPointMake(touchPoint.x-reduction, touchPoint.y-reduction);

    CGRect heartRect = {newPoint, heartIcon.size};

//    NSLog(@"Heart rect %f %f %f %f", heartRect.origin.x,heartRect.origin.y,heartRect.size.width, heartRect.size.height);

    UIGraphicsBeginImageContext(overlaySize);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect inputRect = {CGPointZero, overlaySize};
    CGContextClearRect(context, inputRect);

    CGAffineTransform flip = CGAffineTransformMakeScale(1.0, -1.0);
    CGAffineTransform flipThenShift = CGAffineTransformTranslate(flip,0,-overlaySize.height);
    CGContextConcatCTM(context, flipThenShift);
    CGRect transformedGhostRect = CGRectApplyAffineTransform(heartRect, flipThenShift);

    CGContextDrawImage(context, transformedGhostRect, [heartIcon CGImage]);

    UIImage *flameyIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return flameyIcon;
}

- (void)renderLateralTable {
    NSLog(@"Render annotation table");
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
    [_selectedPhotosTable setTransform:rotate];

    // Table Background View Informative or a button??
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kAnnotationTableEmptyMessageView owner:nil options:nil];
    UIView *view = [nibContents lastObject];
    [view setFrame:tableRect];
    [view setCenter:_selectedPhotosTable.center];
    [_selectedPhotosTable setBackgroundView:view];
    CGAffineTransform clockwiseRotate = CGAffineTransformMakeRotation(M_PI_2);

    [_selectedPhotosTable.backgroundView setTransform:clockwiseRotate];
    [_selectedPhotosTable.backgroundView setHidden:YES];
}

- (void)setTableViewEmptyMessage:(BOOL)show {
    if (show) {
        [_selectedPhotosTable.backgroundView setHidden:NO];
    } else {
        [_selectedPhotosTable.backgroundView setHidden:YES];
    }
}

#pragma UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_DEVELOPMENT_ENV) {
        return 1;
    } else {
        FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];

        return [annotationStore.photos count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];

    // TODO: review this xib load pattern
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kAnnotationTableViewCellIdentifier owner:nil options:nil];
    FLAnnotationTableViewCell *cell = [nibContents lastObject];
    FLPhoto *photo = [annotationStore.photos objectAtIndex:[indexPath row]];
    cell.photo = photo;

    if([tableView isEqual:_selectedPhotosTable]) {
        if (_DEVELOPMENT_ENV) {

            UIImage *testImage = [UIImage imageNamed:@"test_image"];

            [cell.selectedImageViewBackground setImage:testImage];

            cell.originalImage = testImage;
            [cell.contentView setUserInteractionEnabled:YES];
            cell.selectedImageViewBackground.transform = CGAffineTransformMakeRotation(M_PI_2);
        } else {
            [cell.selectedImageViewBackground sd_setImageWithURL:[NSURL URLWithString:photo.URL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

                cell.originalImage = image;
                [cell.contentView setUserInteractionEnabled:YES];

                cell.selectedImageViewBackground.transform = CGAffineTransformMakeRotation(M_PI_2);
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

- (void)deletePhotoFromStoreAndSlideTable {
    NSArray *visible       = [self.selectedPhotosTable indexPathsForVisibleRows];
    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];

    FLAnnotationTableViewCell *cell = (FLAnnotationTableViewCell *)[_selectedPhotosTable cellForRowAtIndexPath:indexpath];
    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];
    [annotationStore.photos removeObjectAtIndex:[indexpath row]];

    FLProcessedImagesStore *processedPhotoStore = [FLProcessedImagesStore sharedStore];
    [processedPhotoStore removePhotoById:(NSString *)cell.photo.id];

    if ([annotationStore.photos count] == 0) {
        [_selectedPhotosTable.backgroundView setHidden:NO];
    }

    [_selectedPhotosTable deleteRowsAtIndexPaths:@[indexpath]
                                withRowAnimation:UITableViewRowAnimationLeft];

    [self updateUploadButtonState];
}

//- (void)deletePhotoFromStoreAndSlideTable {
//    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];
//    NSLog(@"**** Count Before %lu, ", [annotationStore.photos count]);
//    FLProcessedImagesStore *processedImageStore = [FLProcessedImagesStore sharedStore];
//
//    NSArray *visible       = [self.selectedPhotosTable indexPathsForVisibleRows];
//    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];
//
//    FLAnnotationTableViewCell *cell = (FLAnnotationTableViewCell *)[_selectedPhotosTable cellForRowAtIndexPath:indexpath];
//
//    // Isolate problem
////    [annotationStore removePhotoById:cell.photo.id];
//
//    NSLog(@"**** Count After %lu, ", [annotationStore.photos count]);
//
////    [_selectedPhotosTable reloadData];
//    [_selectedPhotosTable deleteRowsAtIndexPaths:@[indexpath]
//                                withRowAnimation:UITableViewRowAnimationLeft];
//
////
//////    NSString *photoId = [NSString stringWithFormat:@"%lu", (unsigned long) cell.photo.id];
//
////
//////    [annotationStore.photos removeObjectAtIndex:indexpath.row];
////
////    [processedImageStore removePhotoById:(NSString *)cell.photo.id];
//
//    if ([annotationStore.photos count] == 0) {
//        [_selectedPhotosTable.backgroundView setHidden:NO];
//    }
//
//    [self updateUploadButtonState];
//}

- (IBAction)removePhotoAction:(id)sender {
    [self deletePhotoFromStoreAndSlideTable];
}

- (IBAction)keepPhoto:(id)sender {

//    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}
@end