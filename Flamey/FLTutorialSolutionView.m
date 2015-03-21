//
//  FLTutorialView.m
//  Flamey
//
//  Created by Shane Rogers on 3/4/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialSolutionView.h"

NSString *const kCompleteTutorial = @"completeTutorial";

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

- (IBAction)selectFirstPersona:(id)sender {
    NSLog(@"selectFirstPersona");
    [_tutorialImageView setImage:[UIImage imageNamed:kMaleOneSelected]];

    [_finishButton setHidden:NO];
}

- (IBAction)selectSecondPersona:(id)sender {
    NSLog(@"selectSecondPersona");
    [_tutorialImageView setImage:[UIImage imageNamed:kMaleTwoSelected]];

    [_finishButton setHidden:NO];
}

- (IBAction)selectThirdPersona:(id)sender {
    NSLog(@"selectThirdPersona");
    [_tutorialImageView setImage:[UIImage imageNamed:kMaleThreeSelected]];

    [_finishButton setHidden:NO];
}

- (IBAction)finishTutorial:(id)sender {
    // Update to trigger a slide to next step notification
    NSNotification *notification = [NSNotification notificationWithName:kCompleteTutorial
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 */

@end
