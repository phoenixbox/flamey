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
@property (strong, nonatomic) UITableView *selectedPhotosTable;
@property (assign, nonatomic) BOOL DEVELOPMENT_ENV;

@end

static NSString * const kAnnotationTableViewCellIdentifier = @"FLAnnotationTableViewCell";

@implementation FLImageAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _DEVELOPMENT_ENV = false;

    [self renderLateralTable];

    // TODO: Update filters flow
    [_addFiltersButton setHidden:YES];

    [self updateAnnotationStore];
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

    FLPhoto *processedPhoto = [[FLPhoto alloc] init];
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
                // Entry point for slide to remove cell?
            }];
        }
    }
    return cell;
}

//- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView
//           editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return UITableViewCellEditingStyleDelete;
//}
//
//- (void) setEditing:(BOOL)editing animated:(BOOL)animated{
//    [super setEditing:editing
//             animated:animated];
//    [_selectedPhotosTable setEditing:editing
//                            animated:animated];
//}
//
//- (void) tableView:(UITableView *)tableView
//commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
// forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (editingStyle == UITableViewCellEditingStyleDelete) {
//        /* First remove this object from the source */
//        FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];
//        [annotationStore.photos removeObjectAtIndex:indexPath.row];
//        /* Then remove the associated cell from the Table View */
//        [tableView deleteRowsAtIndexPaths:@[indexPath]
//                         withRowAnimation:UITableViewRowAnimationLeft];
//    }
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.view.frame.size.width;
}

//#pragma mark - MDCSwipeToChooseDelegate Callbacks
//
//// This is called when a user didn't fully swipe left or right.
//- (void)viewDidCancelSwipe:(UIView *)view {
//    NSLog(@"Couldn't decide, huh?");
//}
//
//// Sent before a choice is made. Cancel the choice by returning `NO`. Otherwise return `YES`.
//- (BOOL)view:(UIView *)view shouldBeChosenWithDirection:(MDCSwipeDirection)direction {
//    if (direction == MDCSwipeDirectionRight) {
//        return YES;
//    } else {
//        // Snap the view back and cancel the choice.
//        [UIView animateWithDuration:0.16 animations:^{
//            view.transform = CGAffineTransformIdentity;
//            view.center = _tableContainer.center;
//        }];
//        return NO;
//    }
//}
//
//// This is called then a user swipes the view fully left or right.
//- (void)view:(UIView *)view wasChosenWithDirection:(MDCSwipeDirection)direction {
//    if (direction == MDCSwipeDirectionRight) {
//        NSLog(@"Photo deleted!");
//    } else {
//        NSLog(@"Photo saved!");
//    }
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)removePhotoAction:(id)sender {
    NSArray *visible       = [self.selectedPhotosTable indexPathsForVisibleRows];
    NSIndexPath *indexpath = (NSIndexPath*)[visible objectAtIndex:0];

    FLAnnotationStore *annotationStore = [FLAnnotationStore sharedStore];
    [annotationStore.photos removeObjectAtIndex:indexpath.row];

    [_selectedPhotosTable deleteRowsAtIndexPaths:@[indexpath]
                     withRowAnimation:UITableViewRowAnimationLeft];
}

- (IBAction)keepPhoto:(id)sender {

//    [self.frontCardView mdc_swipe:MDCSwipeDirectionRight];
}
@end