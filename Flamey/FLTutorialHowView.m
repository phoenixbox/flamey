//
//  FLTutorialHowView.m
//  Flamey
//
//  Created by Shane Rogers on 3/8/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialHowView.h"

NSString *const kContinueTutorial = @"continueTutorial";

@implementation FLTutorialHowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)continue:(id)sender {
    // Update to trigger a slide to next step notification
    NSNotification *notification = [NSNotification notificationWithName:kContinueTutorial
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];

}
@end
