//
//  FLTutorialView.m
//  Flamey
//
//  Created by Shane Rogers on 3/4/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialSolutionView.h"
#import <FacebookSDK/FacebookSDK.h>

// Data Layer
#import "FLSettings.h"

// Pods
#import "Mixpanel.h"

NSString *const kCompleteSolutionTutorial = @"completeSolution";

// Male Image Constants
NSString *const kMaleZeroSelected = @"Male-0-Selected";
NSString *const kMaleOneSelected = @"Male-1-Selected";
NSString *const kMaleTwoSelected = @"Male-2-Selected";
NSString *const kMaleThreeSelected = @"Male-3-Selected";

// Female Image Constants
NSString *const kFemaleZeroSelected = @"Female-0-Selected";
NSString *const kFemaleOneSelected = @"Female-1-Selected";
NSString *const kFemaleTwoSelected = @"Female-2-Selected";
NSString *const kFemaleThreeSelected = @"Female-3-Selected";

NSString *const kMale = @"male";
NSString *const kFemale = @"female";

@implementation FLTutorialSolutionView

- (void)setNeedsDisplay {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews {
    _contentView.layer.cornerRadius = 10;
    _contentView.clipsToBounds = YES;
    [self setDefaultZeroSelectedImage];

    [self setSelectedPersona];

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"loaded"
                                               }];
}

- (void)setSelectedPersona {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    NSString *selectedPersona = [[FLSettings defaultSettings] selectedPersona];

    if (selectedPersona) {
        [_finishButton setHidden:NO];

        if (user.isMale) {
            [self setMalePersonaImages:selectedPersona];
        } else if (user.isFemale) {
            [self setFemalePersonaImages:selectedPersona];
        } else {
            NSLog(@"!WARN! Gender is not defined");
            [self setDefaultZeroSelectedImage];
        }
    } else {
        [self setDefaultZeroSelectedImage];
    }
}

- (void)setDefaultZeroSelectedImage {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    if (user.isMale) {
        [_tutorialImageView setImage:[UIImage imageNamed:kMaleZeroSelected]];
    } else if (user.isFemale) {
        [_tutorialImageView setImage:[UIImage imageNamed:kFemaleZeroSelected]];
    } else {
        NSLog(@"!WARN! Gender is not defined");
    }
}

- (void)setMalePersonaImages:(NSString *)selectedPersona {
    if ([selectedPersona isEqualToString:kMaleOneSelected]) {
        [_tutorialImageView setImage:[UIImage imageNamed:kMaleOneSelected]];
    } else if ([selectedPersona isEqualToString:kMaleTwoSelected]) {
        [_tutorialImageView setImage:[UIImage imageNamed:kMaleTwoSelected]];
    } else if ([selectedPersona isEqualToString:kMaleThreeSelected]) {
        [_tutorialImageView setImage:[UIImage imageNamed:kMaleThreeSelected]];
    } else {
        NSLog(@"!WARN! The set MALE persona is not defined");
    }
}

- (void)setFemalePersonaImages:(NSString *)selectedPersona {
    if ([selectedPersona isEqualToString:kFemaleOneSelected]) {
        [_tutorialImageView setImage:[UIImage imageNamed:kFemaleOneSelected]];
    } else if ([selectedPersona isEqualToString:kFemaleTwoSelected]) {
        [_tutorialImageView setImage:[UIImage imageNamed:kFemaleTwoSelected]];
    } else if ([selectedPersona isEqualToString:kFemaleThreeSelected]) {
        [_tutorialImageView setImage:[UIImage imageNamed:kFemaleThreeSelected]];
    } else {
        NSLog(@"!WARN! The set FEMALE persona is not defined");
    }
}

- (void)setLabels {
    float titleFontSize;
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        // iPhone 4 - 3.5
        titleFontSize = 15.0f;
    } else if ([UIScreen mainScreen].bounds.size.height == 568) {
        // iPhone 5 - 4in
        titleFontSize = 16.0f;
    } else if ([UIScreen mainScreen].bounds.size.width == 375) {
        // iPhone 6 - 4.7in
        titleFontSize = 16.0f;
    } else if ([UIScreen mainScreen].bounds.size.width == 414) {
        // iPhone 6+ - 5.5in
        titleFontSize = 16.0f;
    } else if ([UIScreen mainScreen].bounds.size.width == 768) {
        // iPad
        NSLog(@"!WARN!: iPad not designed for");
        titleFontSize = 16.0f;
    }

    _tutorialTitle.font = [UIFont fontWithName:@"AvenirNext-Regular" size:titleFontSize];
}

- (IBAction)selectFirstPersona:(id)sender {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    if (user.isMale) {
        [_tutorialImageView setImage:[UIImage imageNamed:kMaleOneSelected]];
        [[FLSettings defaultSettings] setSelectedPersona:kMaleOneSelected];
    } else if (user.isFemale) {
        [_tutorialImageView setImage:[UIImage imageNamed:kFemaleOneSelected]];
        [[FLSettings defaultSettings] setSelectedPersona:kFemaleOneSelected];
    } else {
        NSLog(@"!WARN!: No Gender Defined");
    }

    [_finishButton setHidden:NO];
}

- (IBAction)selectSecondPersona:(id)sender {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    if (user.isMale) {
        [_tutorialImageView setImage:[UIImage imageNamed:kMaleTwoSelected]];
        [[FLSettings defaultSettings] setSelectedPersona:kMaleTwoSelected];
    } else if (user.isFemale) {
        [_tutorialImageView setImage:[UIImage imageNamed:kFemaleTwoSelected]];
        [[FLSettings defaultSettings] setSelectedPersona:kFemaleTwoSelected];
    } else {
        NSLog(@"!WARN!: No Gender Defined");
    }

    [_finishButton setHidden:NO];
}

- (IBAction)selectThirdPersona:(id)sender {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    if (user.isMale) {
        [_tutorialImageView setImage:[UIImage imageNamed:kMaleThreeSelected]];
        [[FLSettings defaultSettings] setSelectedPersona:kMaleThreeSelected];
    } else if (user.isFemale) {
        [_tutorialImageView setImage:[UIImage imageNamed:kFemaleThreeSelected]];
        [[FLSettings defaultSettings] setSelectedPersona:kFemaleThreeSelected];
    } else {
        NSLog(@"!WARN!: No Gender Defined");
    }

    [_finishButton setHidden:NO];
}

- (IBAction)completeSolution:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Education" properties:@{
                                                @"controller": NSStringFromClass([self class]),
                                                @"state": @"complete",
                                                @"persona": [[FLSettings defaultSettings] selectedPersona]
                                                }];

    NSNotification *notification = [NSNotification notificationWithName:kCompleteSolutionTutorial
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 */

- (IBAction)exitTutorial:(id)sender {
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
@end
