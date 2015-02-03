//
//  FLFiltersStore.m
//  Flamey
//
//  Created by Shane Rogers on 2/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFiltersStore.h"

// GPUImage Imports
#import "GPUImageMonochromeFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageView.h"
#import "GPUImagePicture.h"
#import "GPUImageSaturationFilter.h"
#import "GPUImageVignetteFilter.h"
#import "GPUImageExposureFilter.h"
#import "GPUImageFilterGroup.h"
#import "GPUImageGrayscaleFilter.h"
#import "GPUImageAlphaBlendFilter.h"
#import "GPUImageGaussianBlurFilter.h"

// If just using the reference images we dont need the other filter imports
#import "GPUImageLookupFilter.h"

#define kOriginal @"original"

@interface FLFiltersStore ()

@property (nonatomic, strong) NSMutableArray *filterOptions;

@end

@implementation FLFiltersStore

+ (instancetype)sharedStore {
    static id filterStore = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        filterStore = [[self alloc] init];
    });

    return filterStore;
}

- (void)generateFiltersForImage:(UIImage *)image {
    NSArray *filterTypes = @[
                             kOriginal,
                             @"lookup_cooling.png",
                             @"lookup_cooling2.png",
                             @"lookup_filter1.png",
                             @"lookup_filter2.png",
                             @"lookup_highkey.png",
                             @"lookup_infrared.png",
                             @"lookup_sepia.png",
                             @"lookup_sepia2.png",
                             @"lookup_vibrance.png",
                             @"lookup_warming.png"];

    // TODO: Combine to dicts when social media appraisal done
    NSArray *filterNames = @[
                             @"Original",
                             @"Smates",
                             @"Replete",
                             @"Flix",
                             @"P183",
                             @"Snub 23",
                             @"TEaton",
                             @"Robin",
                             @"Melbourne",
                             @"Bushwick",
                             @"Obey"
                             ];

    NSArray *overlays = @[
                          @"O",
                          @"S",
                          @"R",
                          @"F",
                          @"183",
                          @"S",
                          @"T",
                          @"R",
                          @"M",
                          @"B",
                          @"O"
                          ];

    NSMutableArray *options = [NSMutableArray new];

    for (int index = 0; index < [filterTypes count]; index++) {
        UIImage *filteredImage;
        UIImage *blurredImage;
        NSString *filename = [filterTypes objectAtIndex:index];

        if ([filename isEqual:kOriginal]) {
            NSLog(@"original image");
            filteredImage = image;
        } else {
            filteredImage = [self filteredImage:image withFilter:filename];
        }

        blurredImage = [self blurImage:filteredImage];
        NSDictionary *filteredDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                            filteredImage, @"filteredImage",
                                            filename, @"filename",
                                            [filterNames objectAtIndex:index], @"filterName",
                                            blurredImage, @"blurredImage",
                                            [overlays objectAtIndex:index], @"overlay", nil];

        [options addObject:filteredDictionary];
    }

    self.filterOptions = options;
}

- (UIImage *)filteredImage:(UIImage *)image withFilter:(NSString *)filename {
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:filename]];
    NSLog(@"%@", filename);
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];

    [stillImageSource addTarget:lookupFilter];
    [lookupImageSource addTarget:lookupFilter];

    [stillImageSource processImage];
    [lookupImageSource processImage];

    [lookupFilter useNextFrameForImageCapture];

    return [lookupFilter imageFromCurrentFramebufferWithOrientation:image.imageOrientation];
}

- (UIImage *)blurImage:(UIImage *)image {
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:image];
    GPUImageGaussianBlurFilter *stillImageFilter = [[GPUImageGaussianBlurFilter alloc] init];
    [stillImageFilter setBlurRadiusInPixels:30.0];

    [stillImageSource addTarget:stillImageFilter];
    [stillImageFilter useNextFrameForImageCapture];
    [stillImageSource processImage];

    return [stillImageFilter imageFromCurrentFramebuffer];
}

- (NSMutableArray *)allFilters {
    return [self filterOptions];
}

@end