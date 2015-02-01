//
//  FLToolsStore.h
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "GPUImage.h"

typedef enum {
    ART_ADJUST,
    ART_BRIGHTNESS,
    ART_CONTRAST,
    ART_HIGHLIGHTS,
    ART_SHADOWS,
    ART_SATURATION,
    ART_VIGNETTE,
    ART_WARMTH,
    ART_TILTSHIFT,
    ART_SHARPEN
} ARTToolType;

extern NSString *const kFilterTool;
extern NSString *const kFilterSlider;

@interface FLToolsStore : NSObject {
    GPUImageOutput<GPUImageInput> *filter;
}

+ (instancetype)sharedStore;
+ (void)setupSlider:(UISlider *)slider forFilterType:(ARTToolType)toolType;

- (NSMutableArray *)allTools;

- (void)generateToolOptions;

@end