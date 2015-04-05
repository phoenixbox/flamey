//
//  FLTutorialProcessView.m
//  Flamey
//
//  Created by Shane Rogers on 3/21/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialProcessView.h"
#import "FLTutorialSolutionView.h"

// Data Layer
#import "FLSettings.h"
#import "FLUser.h"

NSString *const kCompleteProcess = @"completeProcess";

// Image Type Constants
NSString *const kPersonaImage = @"personaImage";
NSString *const kUploadImage = @"uploadImage";

// Asset Image Consts
// Male
NSString *const kMaleImageOne = @"Selected-Male-1";
NSString *const kMaleImageTwo = @"Selected-Male-2";
NSString *const kMaleImageThree = @"Selected-Male-3";
NSString *const kMaleUploadOne = @"MaleUploadOne";
NSString *const kMaleUploadTwo = @"MaleUploadTwo";
NSString *const kMaleUploadThree = @"MaleUploadThree";

// Male
NSString *const kFemaleImageOne = @"Selected-Female-1";
NSString *const kFemaleImageTwo = @"Selected-Female-2";
NSString *const kFemaleImageThree = @"Selected-Female-3";
NSString *const kFemaleUploadOne = @"FemaleUploadOne";
NSString *const kFemaleUploadTwo = @"FemaleUploadTwo";
NSString *const kFemaleUploadThree = @"FemaleUploadThree";

// Helpers
#import "FLViewHelpers.h"

@implementation FLTutorialProcessView

- (void)setNeedsDisplay {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews {
    _contentView.layer.cornerRadius = 10;
    _contentView.clipsToBounds = YES;

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"loaded"
                                               }];
}

- (IBAction)next:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Education" properties:@{
                                             @"controller": NSStringFromClass([self class]),
                                             @"state": @"complete",
                                             @"persona": [[FLSettings defaultSettings] selectedPersona]
                                             }];
    NSNotification *notification = [NSNotification notificationWithName:kCompleteProcess
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)completeTutorial:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Education" properties:@{
                                             @"controller": NSStringFromClass([self class]),
                                             @"state": @"exit",
                                             @"persona": [[FLSettings defaultSettings] selectedPersona]
                                             }];
    NSNotification *notification = [NSNotification notificationWithName:@"completeTutorial"
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)setContent {
    [self setFirstSectionContent];
    [self setSecondSectionContent];
    [self setThirdSectionContent];
    [self setStartButtonStyleAndCopy];
}

- (void)setFirstSectionContent {
    // Set the copy
    NSString *copy = @"stndout lets you\n mark yourself in your\n facebook photos";
    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];;

    _firstCopy.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _firstCopy.textColor = [UIColor blackColor];
    _firstCopy.lineBreakMode = NSLineBreakByWordWrapping;
    _firstCopy.numberOfLines = 3;

    [_firstCopy setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"stndout" options:NSCaseInsensitiveSearch];

        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];

    // Set the image view
    NSDictionary *imagesForView = [self imagesForSelectedPersona];
    NSString *imageName = [imagesForView objectForKey:kPersonaImage];
    [_firstImageView setImage:[UIImage imageNamed:imageName]];
    [_firstImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (NSDictionary *)imagesForSelectedPersona {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    NSString *personaImage;
    NSString *uploadImage;

    NSString *selectedPersona = [[FLSettings defaultSettings] selectedPersona];

    if (user.isMale) {
        if ([selectedPersona isEqualToString:kMaleOneSelected]) {
            personaImage = kMaleImageOne;
            uploadImage = kMaleUploadOne;
        } else if ([selectedPersona isEqualToString:kMaleTwoSelected]) {
            personaImage = kMaleImageTwo;
            uploadImage = kMaleUploadTwo;
        } else if ([selectedPersona isEqualToString:kMaleThreeSelected]) {
            personaImage = kMaleImageThree;
            uploadImage = kMaleUploadThree;
        } else {
            NSLog(@"!WARN! no persona set in the settings");
            personaImage = kMaleImageOne;
            uploadImage = kMaleUploadOne;
        }
    } else if (user.isFemale) {
        if ([selectedPersona isEqualToString:kFemaleOneSelected]) {
            personaImage = kFemaleImageOne;
            uploadImage = kFemaleUploadOne;
        } else if ([selectedPersona isEqualToString:kFemaleTwoSelected]) {
            personaImage = kFemaleImageTwo;
            uploadImage = kFemaleUploadTwo;
        } else if ([selectedPersona isEqualToString:kFemaleThreeSelected]) {
            personaImage = kFemaleImageThree;
            uploadImage = kFemaleUploadThree;
        } else {
            NSLog(@"!WARN! no persona set in the settings");
            personaImage = kFemaleImageOne;
            uploadImage = kFemaleUploadOne;
        }
    } else {
        NSLog(@"!WARN! No gender is defined");
    }

    return @{ @"personaImage": personaImage, @"uploadImage": uploadImage };
}


- (void)setSecondSectionContent {
    NSString *copy = @"We upload these photos\n privately to facebook where\n only you can see them\nGuaranteed";
    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];;

    _secondCopy.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _secondCopy.textColor = [UIColor blackColor];
    _secondCopy.lineBreakMode = NSLineBreakByWordWrapping;
    _secondCopy.numberOfLines = 5;

    [_secondCopy setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRangeOne = [[mutableAttributedString string] rangeOfString:@"privately" options:NSCaseInsensitiveSearch];
        NSRange boldRangeTwo = [[mutableAttributedString string] rangeOfString:@"Guaranteed" options:NSCaseInsensitiveSearch];

        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRangeOne];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRangeTwo];
;
            CFRelease(font);
        }

        return mutableAttributedString;
    }];

    // Set the image view
    NSDictionary *imagesForView = [self imagesForSelectedPersona];
    NSString *imageName = [imagesForView objectForKey:kUploadImage];
    [_secondImageView setImage:[UIImage imageNamed:imageName]];
    [_secondImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setThirdSectionContent {
    NSString *copy = @"Your dating apps can then pick up these\n secret hidden photos";
    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];;

    _thirdCopy.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _thirdCopy.textColor = [UIColor blackColor];
    _thirdCopy.lineBreakMode = NSLineBreakByWordWrapping;
    _thirdCopy.numberOfLines = 3;

    [_thirdCopy setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRangeOne = [[mutableAttributedString string] rangeOfString:@"secret" options:NSCaseInsensitiveSearch];
        NSRange boldRangeTwo = [[mutableAttributedString string] rangeOfString:@"hidden" options:NSCaseInsensitiveSearch];

        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRangeOne];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRangeTwo];

            CFRelease(font);
        }

        return mutableAttributedString;
    }];

    // Set the image view
    [_thirdImageView setImage:[UIImage imageNamed:@"DatingApps"]];
    [_thirdImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setStartButtonStyleAndCopy {
    [FLViewHelpers setBaseButtonStyle:_nextButton withColor:[UIColor blackColor]];
    float buttonCopySize = [FLViewHelpers buttonCopyForScreenSize];
    [_nextButton setTitle:@"Awesome!" forState:UIControlStateNormal];

    _nextButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:buttonCopySize];
}

@end
