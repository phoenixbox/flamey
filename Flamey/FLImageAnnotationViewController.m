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

// Pods
#import <SDWebImage/UIImageView+WebCache.h>

// Data Layer
#import "FLPhotoStore.h"
#import "FLProcessedImagesStore.h"

// Pods
#import "GPUImageLookupFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageAlphaBlendFilter.h"

@interface FLImageAnnotationViewController ()

@property (nonatomic, strong) UIImage *facebookImage;
@property (nonatomic, strong) UITapGestureRecognizer *imageViewTap;

@end

@implementation FLImageAnnotationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [_photoImageView sd_setImageWithURL:[NSURL URLWithString:self.selectedPhoto.URL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"imageView phto set");

        _facebookImage = image;

        [self addTapGestureRecogniserToImageView];
    }];
}

- (void)addTapGestureRecogniserToImageView {
    NSLog(@"SETTING");
    self.imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(setFlameIcon:)];
    self.imageViewTap.numberOfTouchesRequired = 1;
    self.imageViewTap.numberOfTapsRequired = 1;

    [_photoImageView addGestureRecognizer:self.imageViewTap];
    // NOTE: Must set interaction true so that the gesture can be triggered. Dont have to have selector on the filter ImageView
    _photoImageView.userInteractionEnabled = YES;
}

- (void)setFlameIcon:(UIGestureRecognizer *)gr {
    NSLog(@"Recognized tap");

    // Base Image
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:_facebookImage];

    // Flame Image
    CGPoint point = [gr locationInView:_photoImageView];
    UIImage *overlayImage = [self createFlame:_photoImageView.frame.size atTouchPoint:point];
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

    [_photoImageView setImage:processedImage];
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



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
