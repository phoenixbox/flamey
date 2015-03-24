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
#import "FLAnnotationTableEmptyMessageView.h"

// Pods
#import <SDWebImage/UIImageView+WebCache.h>

// Data Layer
#import "FLSelectedPhotoStore.h"
#import "FLProcessedImagesStore.h"
#import "FLAnnotationStore.h"

// Pods
#import "GPUImageLookupFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageAlphaBlendFilter.h"

// Helpers
#import "FLViewHelpers.h"

@interface FLImageAnnotationViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *imageViewTap;
@property (nonatomic, strong) UIPanGestureRecognizer *moveRecognizer;
@property (strong, nonatomic) UITableView *selectedPhotosTable;

@end

static NSString * const kAnnotationTableViewCellIdentifier = @"FLAnnotationTableViewCell";
static NSString * const kAnnotationTableEmptyMessageView = @"FLAnnotationTableEmptyMessageView";
// TODO: these segue identifiers should be composed to a common level of abstraction
static NSString * const kAddMorePhotosSegueIdentifier = @"getFacebookPhotos";

@implementation FLImageAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self updateUploadButtonState];
    [self setHeaderLogo];
    [self renderLateralTable];
    [self setRemoveButtonActive];
    [self checkToDisableNavigationArrows];

    // TODO: Update filters flow
    [_addFiltersButton setHidden:YES];
    [self updateAnnotationStore];
    [self addAddMorePhotosListener];
}
// RESTART: style the upload view
- (void)setHeaderLogo {
    [[self navigationItem] setTitleView:nil];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    self.navigationItem.titleView = logoView;
}

- (void)addAddMorePhotosListener {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(addMorePhotos)
                   name:kAddMorePhotos
                 object:nil];
}

- (void)addMorePhotos {
    [self performSegueWithIdentifier:kAddMorePhotosSegueIdentifier sender:self];
}

- (void)updateUploadButtonState {
    NSUInteger count = [[FLProcessedImagesStore sharedStore].photos count];

    if (count == 0) {
        [self setUploadButtonsInactive];
    } else {
        [_uploadButton setUserInteractionEnabled:YES];
        [FLViewHelpers setBaseButtonStyle:_uploadButton withColor:[UIColor blackColor]];
        NSString *buttonTitle = [NSString stringWithFormat:@"Upload %lu Private Photos", (unsigned long)count];

        [_uploadButton setTitle:buttonTitle forState:UIControlStateNormal];
        [_uploadButton.titleLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
    }
}

// Update style setting on initial load for removal button
// Decouple style state setting functions

- (void)setRemoveButtonActive {
    [_removeSelectedPhoto setUserInteractionEnabled:YES];
    [FLViewHelpers setBaseButtonStyle:_removeSelectedPhoto withColor:[UIColor redColor]];
    [_removeSelectedPhoto setImage:[UIImage imageNamed:@"Trash"] forState:UIControlStateNormal];
    [_removeSelectedPhoto setTitle:@"" forState:UIControlStateNormal];
}

- (void)setRemoveButtonInactive {
    [_removeSelectedPhoto setUserInteractionEnabled:NO];
    [FLViewHelpers setBaseButtonStyle:_removeSelectedPhoto withColor:[UIColor grayColor]];
    [_removeSelectedPhoto setBackgroundColor:[UIColor whiteColor]];
    [_removeSelectedPhoto setImage:nil forState:UIControlStateNormal];
    [_removeSelectedPhoto setTitle:@"" forState:UIControlStateNormal];
}

- (void)setUploadButtonsInactive {
    [_uploadButton setUserInteractionEnabled:NO];
    [FLViewHelpers setBaseButtonStyle:_uploadButton withColor:[UIColor grayColor]];
    [_uploadButton setTitle:@"No Photos Marked" forState:UIControlStateNormal];

}

- (void)viewDidAppear:(BOOL)animated {
    if (_targetRow) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:_targetRow inSection:0];

        [_selectedPhotosTable scrollToRowAtIndexPath:indexPath
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
    } else {
        [self checkToDisableNavigationArrows];
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

- (void)addTapGestureRecognizerToCell:(FLAnnotationTableViewCell *)cell {
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

    // Set annotation locations
    [targetCell.photo setAnnotationPoint:annotationPoint];
    [self setLogoLocation:targetCell];

    // Overlay images on media
    [self setImagesOnCell:targetCell];

    [self updateUploadButtonState];
}

- (void)setLogoLocation:(FLAnnotationTableViewCell *)targetCell {
    UIImageView *imageView = targetCell.selectedImageViewBackground;

    // Adjustments translate to a 20/320 width && 50/320 height
    [targetCell.photo setLogoPoint:CGPointMake(imageView.image.size.width*0.04, (imageView.image.size.height*(1-0.1)) )];
}

//- (void)addPanGestureRecognizerToCell:(FLAnnotationTableViewCell *)cell {
//    self.moveRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self
//                                                                  action:@selector(moveAnnotation:)];
//    [self.moveRecognizer setDelegate:self];
//    [self.moveRecognizer setCancelsTouchesInView:NO];
//
//    [cell addGestureRecognizer:self.moveRecognizer];
//
//    // NOTE: Must set interaction true so that the gesture can be triggered
//    // Dont have to have selector on the filter ImageView
//    cell.userInteractionEnabled = YES;
//}

//#pragma PanGesture Protocol
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
//shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)other
//{
//    if (gestureRecognizer == self.moveRecognizer) {
//        return YES;
//    }
//
//    return NO;
//}
//
//- (void)moveAnnotation:(UIPanGestureRecognizer *)sender {
//    FLAnnotationTableViewCell *targetCell = (FLAnnotationTableViewCell *)sender.view;
//    CGPoint annotationPoint = [sender locationInView:targetCell.selectedImageViewBackground];
//
//    if (CGPointEqualToPoint(targetCell.photo.annotationPoint, CGPointZero)) {
//        [targetCell.photo setAnnotationPoint:annotationPoint];
//    }
//
//    // When the pan recognizer changes its position...
//    if ([sender state] == UIGestureRecognizerStateChanged) {
//        // How far has the pan moved?
//        CGPoint translation = [sender translationInView:targetCell.contentView]; // right view of the cell??
//
//        annotationPoint.x += translation.y;
//        annotationPoint.y -= translation.x;
//
//        targetCell.photo.annotationPoint = annotationPoint;
//
//        // Set the new beginning and end points of the line
//        [self setImagesOnCell:targetCell];
//    }
//}

#pragma Set Image on Photo
- (void)setFlameIconOnCell:(FLAnnotationTableViewCell *)targetCell {
    UIImageView *imageView = targetCell.selectedImageViewBackground;
    // 1. Create the image
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:targetCell.originalImage];

    // Note the overlay image size is the same as the cell image
    CGSize imageOverlaySize = CGSizeMake(imageView.image.size.width, imageView.image.size.height);

    // NOTE: OverlayImage must be the same size as the imageOverlaySize
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

    // 3. Annotate the new photo model with the id of the target cell's photo
    FLPhoto *processedPhoto = [[FLPhoto alloc] init];
    processedPhoto.id = targetCell.photo.id;
    processedPhoto.image = processedImage;
    FLProcessedImagesStore *processedImagesStore = [FLProcessedImagesStore sharedStore];
    [processedImagesStore addUniquePhoto:processedPhoto];

    [imageView setImage:processedImage];

}

- (void)setLogoImageOnCell:(FLAnnotationTableViewCell *)targetCell {
    UIImageView *imageView = targetCell.selectedImageViewBackground;
    // 1. Create the image from the actual image view
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:imageView.image];

    // NOTE: OverlayImage must be the same size as the imageOverlaySize
    CGSize imageOverlaySize = CGSizeMake(imageView.image.size.width, imageView.image.size.height);

    UIImage *overlayImage = [self createLogoForSize:imageOverlaySize atTouchPoint:targetCell.photo.logoPoint];

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

    // 3. Annotate the new photo model with the id of the target cell's photo
    FLPhoto *processedPhoto = [[FLPhoto alloc] init];
    processedPhoto.id = targetCell.photo.id;
    processedPhoto.image = processedImage;
    FLProcessedImagesStore *processedImagesStore = [FLProcessedImagesStore sharedStore];

    // TODO: Will this allow an overwrite
    [processedImagesStore addUniquePhoto:processedPhoto];

    [imageView setImage:processedImage];
}

- (UIImage *)createLogoForSize:(CGSize)cellImageSize atTouchPoint:(CGPoint)touchPoint {
    UIImage * logoImage = [UIImage imageNamed:@"annotationLogo.png"];

    CGSize annotationSize = CGSizeMake(cellImageSize.width * 0.34375, cellImageSize.height * 0.055);
    CGRect logoRect = {touchPoint, annotationSize};

    UIGraphicsBeginImageContext(cellImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect inputRect = {CGPointZero, cellImageSize};
    CGContextClearRect(context, inputRect);

    CGAffineTransform flip = CGAffineTransformMakeScale(1.0, -1.0);
    CGAffineTransform flipThenShift = CGAffineTransformTranslate(flip,0,-cellImageSize.height);
    CGContextConcatCTM(context, flipThenShift);
    CGRect transformedLogoRect = CGRectApplyAffineTransform(logoRect, flipThenShift);

    CGContextDrawImage(context, transformedLogoRect, [logoImage CGImage]);

    UIImage * paddedGhost = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return paddedGhost;
}

- (CGRect)getAnImageViewsImageFrame:(UIImageView *)iv {
    CGSize imageSize = iv.image.size;
    CGFloat imageScale = fminf(CGRectGetWidth(iv.bounds)/imageSize.width, CGRectGetHeight(iv.bounds)/imageSize.height);
    CGSize scaledImageSize = CGSizeMake(imageSize.width*imageScale, imageSize.height*imageScale);
    CGRect imageFrame = CGRectMake(roundf(0.5f*(CGRectGetWidth(iv.bounds)-scaledImageSize.width)), roundf(0.5f*(CGRectGetHeight(iv.bounds)-scaledImageSize.height)), roundf(scaledImageSize.width), roundf(scaledImageSize.height));

    return imageFrame;
}

- (UIImage *)createFlameForSize:(CGSize)cellImageSize atTouchPoint:(CGPoint)touchPoint {
    UIImage * logoImage = [UIImage imageNamed:@"logoMarker.png"];

    CGPoint generatedOrigin = [self generateOriginWithPoint:touchPoint forImageSize:cellImageSize];

    CGSize annotationSize = CGSizeMake(cellImageSize.width * 0.085, cellImageSize.width * 0.085);
    CGRect logoRect = {generatedOrigin, annotationSize};

    UIGraphicsBeginImageContext(cellImageSize);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect inputRect = {CGPointZero, cellImageSize};
    CGContextClearRect(context, inputRect);

    CGAffineTransform flip = CGAffineTransformMakeScale(1.0, -1.0);
    CGAffineTransform flipThenShift = CGAffineTransformTranslate(flip,0,-cellImageSize.height);
    CGContextConcatCTM(context, flipThenShift);
    CGRect transformedLogoRect = CGRectApplyAffineTransform(logoRect, flipThenShift);

    CGContextDrawImage(context, transformedLogoRect, [logoImage CGImage]);

    UIImage * paddedGhost = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return paddedGhost;
}

- (CGPoint)generateOriginWithPoint:(CGPoint)touchPoint forImageSize:(CGSize)imageSize {
    float viewWidth = _tableContainer.frame.size.width; // 320
    float viewHeight = _tableContainer.frame.size.height; // 320

    float newX = imageSize.width/viewWidth * touchPoint.x;
    float newY = imageSize.height/viewHeight * touchPoint.y;

    return CGPointMake(newX, newY);
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
    _selectedPhotosTable.scrollEnabled = NO;
    _selectedPhotosTable.showsVerticalScrollIndicator = NO;
    [_selectedPhotosTable setSeparatorColor:[UIColor clearColor]];
    [_selectedPhotosTable setTransform:rotate];

    [self setTableViewBackgroundView:tableRect];

    _selectedPhotosTable.allowsSelection = NO;
}

- (void)setTableViewEmptyMessage:(BOOL)show {
    if (show) {
        [_selectedPhotosTable.backgroundView setHidden:NO];
    } else {
        [_selectedPhotosTable.backgroundView setHidden:YES];
    }
}

// TODO: Refactor common logic/component for empty message view
- (void)setTableViewBackgroundView:(CGRect)tableRect {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kAnnotationTableEmptyMessageView owner:nil options:nil];
    FLAnnotationTableEmptyMessageView *emptyMessage = [nibContents lastObject];
    [emptyMessage setFrame:tableRect];
    [emptyMessage setCenter:_selectedPhotosTable.center];
    [_selectedPhotosTable setBackgroundView:emptyMessage];
    CGAffineTransform clockwiseRotate = CGAffineTransformMakeRotation(M_PI_2);
    [_selectedPhotosTable.backgroundView setTransform:clockwiseRotate];
    [_selectedPhotosTable.backgroundView setHidden:YES];

    emptyMessage.contentView.layer.cornerRadius = 4;
    emptyMessage.contentView.layer.borderWidth = 1;
    emptyMessage.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    [emptyMessage setBackgroundColor:[UIColor whiteColor]];

    [FLViewHelpers setBaseButtonStyle:emptyMessage.addPhotosButton withColor:[UIColor blackColor]];

    [_selectedPhotosTable.backgroundView setTransform:clockwiseRotate];

    [_selectedPhotosTable.backgroundView setHidden:YES];

}

#pragma UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return  [[FLAnnotationStore sharedStore].photos count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];

    // TODO: review this xib load pattern
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kAnnotationTableViewCellIdentifier owner:nil options:nil];
    FLAnnotationTableViewCell *cell = [nibContents lastObject];
    FLPhoto *photo = [annotationStore.photos objectAtIndex:[indexPath row]];
    cell.photo = photo;

    if([tableView isEqual:_selectedPhotosTable]) {
        [cell.selectedImageViewBackground sd_setImageWithURL:[NSURL URLWithString:photo.URL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

            cell.originalImage = image;
            [cell.contentView setUserInteractionEnabled:YES];

            cell.selectedImageViewBackground.transform = CGAffineTransformMakeRotation(M_PI_2);
            // Do I need to reset the frame to retain its size?

            // CGPoint is scalar so comparison to nil wont work - this does :)
            if (!CGPointEqualToPoint(photo.annotationPoint, CGPointZero)) {
                [self setImagesOnCell:cell];
            }

            [self addTapGestureRecognizerToCell:cell];
//            [self addPanGestureRecognizerToCell:cell];
        }];
    }
    return cell;
}

- (void)setImagesOnCell:(FLAnnotationTableViewCell *)cell {
    [self setFlameIconOnCell:cell];
    [self setLogoImageOnCell:cell];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.width;
}

#pragma end

#pragma UIScrollViewDelgate
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self checkToDisableNavigationArrows];
}
#pragma end

- (void)deletePhotoFromStoreAndSlideTable {
    NSArray *visible       = [self.selectedPhotosTable indexPathsForVisibleRows];
    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];

    FLAnnotationTableViewCell *cell = (FLAnnotationTableViewCell *)[_selectedPhotosTable cellForRowAtIndexPath:indexpath];
    // Remove any annotation point associated with the cells photo
    cell.photo.annotationPoint = CGPointZero;

    // Remove the photo from the annotation store
    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];
    [annotationStore.photos removeObjectAtIndex:[indexpath row]];

    FLProcessedImagesStore *processedPhotoStore = [FLProcessedImagesStore sharedStore];
    [processedPhotoStore removePhotoById:(NSString *)cell.photo.id];

    if ([annotationStore.photos count] == 0) {
        [_selectedPhotosTable.backgroundView setHidden:NO];
        [self setRemoveButtonInactive];
        [_scrollRightButton setEnabled:NO];
        [_scrollLeftButton setEnabled:NO];
    }

    [_selectedPhotosTable deleteRowsAtIndexPaths:@[indexpath]
                                withRowAnimation:UITableViewRowAnimationLeft];

    [self updateUploadButtonState];
    [self checkToDisableNavigationArrows];
    [self checkToDisableRemovalButton];
}

- (void)checkToDisableRemovalButton {
    if ([[FLAnnotationStore sharedStore].photos count] == 0) {
        [_removeSelectedPhoto setEnabled:NO];
        [_removeSelectedPhoto setUserInteractionEnabled:NO];
    }
}
// TODO: Setup the buttons with UI for enabled and disabled state so that it can just be toggled
- (void)disableLeftScrollButton {
    [_scrollLeftButton setEnabled:NO];
    [_scrollLeftButton setUserInteractionEnabled:NO];
}

- (void)enableLeftScrollButton {
    [_scrollLeftButton setEnabled:YES];
    [_scrollLeftButton setUserInteractionEnabled:YES];
}

- (void)disableRightScrollButton {
    [_scrollRightButton setEnabled:NO];
    [_scrollRightButton setUserInteractionEnabled:NO];
}

- (void)enableRightScrollButton {
    [_scrollRightButton setEnabled:YES];
    [_scrollRightButton setUserInteractionEnabled:YES];
}

- (void)checkToDisableNavigationArrows {
    NSInteger count = [[FLAnnotationStore sharedStore].photos count];

    if (count != 0) {
        NSArray *visible = [self.selectedPhotosTable indexPathsForVisibleRows];
        NSIndexPath *visibleCellIndexPath = (NSIndexPath*)[visible objectAtIndex:0];
        NSInteger currentRowIndex = visibleCellIndexPath.row;

        if (count == 1) {
            [self disableLeftScrollButton];
            [self disableRightScrollButton];
        } else if (currentRowIndex == 0 & count == 2) {
            [self disableLeftScrollButton];
            [self enableRightScrollButton];
        } else if (currentRowIndex == count-1 & count == 2) {
            [self enableLeftScrollButton];
            [self disableRightScrollButton];
        } else if (currentRowIndex == 0) {
            [self disableLeftScrollButton];
        } else if (currentRowIndex == count-1) {
            [self disableRightScrollButton];
        } else {
            [self enableLeftScrollButton];
            [self enableRightScrollButton];
        }
    } else {
        NSLog(@"There are no annotations left");
    }
}

- (IBAction)removePhotoAction:(id)sender {
    [self deletePhotoFromStoreAndSlideTable];
}

- (IBAction)scrollLeft:(id)sender {
    NSArray *visible = [self.selectedPhotosTable indexPathsForVisibleRows];
    NSIndexPath *visibleCellIndexPath = (NSIndexPath*)[visible objectAtIndex:0];
    NSInteger targetRowIndex = visibleCellIndexPath.row - 1;
    BOOL endOfTable = targetRowIndex < 0;

    if (endOfTable) {
        NSLog(@"WARN: The left scroll button should be disabled");
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetRowIndex inSection:0];
        [_selectedPhotosTable scrollToRowAtIndexPath:indexPath
                                    atScrollPosition:UITableViewScrollPositionBottom
                                            animated:YES];
    }
}

- (IBAction)scrollRight:(id)sender {
    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];
    NSArray *visible  = [self.selectedPhotosTable indexPathsForVisibleRows];
    NSIndexPath *visibleCellIndexPath = (NSIndexPath*)[visible objectAtIndex:0];
    NSInteger targetRowIndex = visibleCellIndexPath.row + 1;
    NSInteger count = [annotationStore.photos count];
    BOOL endOfTable = targetRowIndex >= count;

    if (endOfTable) {
        NSLog(@"WARN: The right scroll button should be disabled");
    } else {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:targetRowIndex inSection:0];
        [_selectedPhotosTable scrollToRowAtIndexPath:indexPath
                                    atScrollPosition:UITableViewScrollPositionTop
                                            animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end