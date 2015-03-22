//
//  FLTutorialView.m
//  Flamey
//
//  Created by Shane Rogers on 3/4/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialSolutionView.h"

// Data Layer
#import "FLSettings.h"

NSString *const kCompleteSolutionTutorial = @"completeSolution";

// Male Image Constants
NSString *const kMaleZeroSelected = @"Male-0-Selected";
NSString *const kMaleOneSelected = @"Male-1-Selected";
NSString *const kMaleTwoSelected = @"Male-2-Selected";
NSString *const kMaleThreeSelected = @"Male-3-Selected";

@implementation FLTutorialSolutionView

- (void)setNeedsDisplay {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)layoutSubviews {
    _contentView.layer.cornerRadius = 10;
    _contentView.clipsToBounds = YES;
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
    NSLog(@"selectFirstPersona");
    [_tutorialImageView setImage:[UIImage imageNamed:kMaleOneSelected]];
    [[FLSettings defaultSettings] setSelectedPersona:kMaleOneSelected];

    [_finishButton setHidden:NO];
}

- (IBAction)selectSecondPersona:(id)sender {
    NSLog(@"selectSecondPersona");
    [_tutorialImageView setImage:[UIImage imageNamed:kMaleTwoSelected]];
    [[FLSettings defaultSettings] setSelectedPersona:kMaleTwoSelected];

    [_finishButton setHidden:NO];
}

- (IBAction)selectThirdPersona:(id)sender {
    NSLog(@"selectThirdPersona");
    [_tutorialImageView setImage:[UIImage imageNamed:kMaleThreeSelected]];
    [[FLSettings defaultSettings] setSelectedPersona:kMaleThreeSelected];

    [_finishButton setHidden:NO];
}

- (IBAction)completeSolution:(id)sender {
    // Update to trigger a slide to next step notification
    NSNotification *notification = [NSNotification notificationWithName:kCompleteSolutionTutorial
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 */

- (IBAction)completeTutorial:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:@"completeTutorial"
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
@end
