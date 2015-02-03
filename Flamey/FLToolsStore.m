//
//  FLToolsStore.m
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLToolsStore.h"

// Constants
#import "FLFilterHelpers.h"

#import "GPUImageFilter.h"
#import "GPUImageBrightnessFilter.h"

NSString *const kFilterTool = @"FilterTool";
NSString *const kFilterSlider = @"FilterSlider";

@interface FLToolsStore ()

@property (nonatomic, strong) NSMutableArray *toolOptions;

@end

@implementation FLToolsStore

+ (instancetype)sharedStore {
    static id toolStore = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        toolStore = [[self alloc] init];
    });

    return toolStore;
}

- (NSMutableArray *)allTools {
    return [self toolOptions];
}

- (void)generateToolOptions {

    NSArray *toolTypes = @[
                           @"adjust.png",
                           @"brightness.png",
                           @"contrast.png",
                           @"highlights.png",
                           @"shadows.png",
                           @"saturation.png",
                           @"vignette.png",
                           @"warmth.png",
                           @"tiltShift.png",
                           @"sharpen.png"];

    // NOTE: Combine to dicts when social media appraisal done
    NSArray *toolNames = @[
                           kAdjustTool,
                           kBrightnessTool,
                           kContrastTool,
                           kHighlightsTool,
                           kShadowsTool,
                           kSaturationTool,
                           kVignetteTool,
                           kWarmthTool,
                           kTiltShiftTool,
                           kSharpenTool];

    NSMutableArray *options = [NSMutableArray new];

    for (int index = 0; index < [toolTypes count]; index++) {
        NSString *filename = [toolTypes objectAtIndex:index];
        NSString *toolName = [toolNames objectAtIndex:index];

        UIImage *toolIcon = [UIImage imageNamed:filename];

        NSDictionary *toolDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                        toolIcon, @"toolIcon",
                                        filename, @"filename",
                                        toolName, @"toolName", nil];

        [options addObject:toolDictionary];
    }
    // Any custom setup work goes here

    self.toolOptions = options;
}

+ (void)setupSlider:(UISlider *)slider forFilterType:(ARTToolType)toolType {
    [slider setValue:0];

    switch (toolType)
    {
        case ART_ADJUST:
        {
            [slider setMinimumValue:-0.0694];
            [slider setMaximumValue:0.0694];
            [slider setValue:0.0];
        }; break;
        case ART_BRIGHTNESS:
        {
            [slider setMinimumValue:-0.5];
            [slider setMaximumValue:1.0];
            [slider setValue:0];
        }; break;
        case ART_CONTRAST:
        {
            [slider setMinimumValue:-0.5];
            [slider setMaximumValue:0.5];
            [slider setValue:0];
        }; break;
        case ART_HIGHLIGHTS:
        {
            [slider setMinimumValue:-1.0];
            [slider setMaximumValue:1.0];
            [slider setValue:0];
        }; break;
        case ART_SHADOWS:
        {
            [slider setMinimumValue:-1.0];
            [slider setMaximumValue:1.0];
            [slider setValue:0];
        }; break;
        case ART_SATURATION:
        {
            [slider setMinimumValue:-1.0];
            [slider setMaximumValue:1.0];
            [slider setValue:0];
        }; break;
        case ART_VIGNETTE:
        {
            [slider setMinimumValue:0.0];
            [slider setMaximumValue:0.15];
            [slider setValue:0];
        }; break;
        case ART_WARMTH:
        {
            [slider setMinimumValue:2500.0];
            [slider setMaximumValue:7500.0];
            [slider setValue:5000.0];
        }; break;
        case ART_TILTSHIFT:
        {
            [slider setMinimumValue:0.2];
            [slider setMaximumValue:0.8];
            [slider setValue:0.5];
        }; break;
        case ART_SHARPEN:
        {
            [slider setMinimumValue:-1.0];
            [slider setMaximumValue:1.0];
            [slider setValue:0];
            break;
        }
        default: {
            NSLog(@"Default");;
        };
    }
}

@end