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

@end

static NSString * const kAnnotationTableViewCellIdentifier = @"FLAnnotationTableViewCell";
static NSString * const kAnnotationTableEmptyMessageView = @"FLAnnotationTableEmptyMessageView";

@implementation FLImageAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
        [_uploadButton setBackgroundColor:[UIColor grayColor]];
        [_uploadButton setAlpha:0.5];
        NSString *buttonTitle = [NSString stringWithFormat:@"Upload %lu Private Photos", (unsigned long)count];
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
    _selectedPhotosTable.scrollEnabled = NO;
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
    [self checkToDisableNavigationArrows];
}

// TODO: Setup the buttons with UI for enabled and disabled state so that it can just be toggled
- (void)disableLeftScrollButton {
    [_scrollLeftButton setBackgroundColor:[UIColor redColor]];
    [_scrollLeftButton setUserInteractionEnabled:NO];
}

- (void)enableLeftScrollButton {
    [_scrollLeftButton setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollLeftButton setUserInteractionEnabled:YES];
}

- (void)disableRightScrollButton {
    [_scrollRightButton setBackgroundColor:[UIColor redColor]];
    [_scrollRightButton setUserInteractionEnabled:NO];
}

- (void)enableRightScrollButton {
    [_scrollRightButton setBackgroundColor:[UIColor lightGrayColor]];
    [_scrollRightButton setUserInteractionEnabled:YES];
}

- (void)checkToDisableNavigationArrows {
    NSInteger count = [[FLAnnotationStore sharedStore].photos count];

    if (count != 0) {
        NSArray *visible = [self.selectedPhotosTable indexPathsForVisibleRows];
        NSIndexPath *visibleCellIndexPath = (NSIndexPath*)[visible objectAtIndex:0];
        NSInteger currentRowIndex = visibleCellIndexPath.row;

        if (currentRowIndex == 0 & count == 2) {
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