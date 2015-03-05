//
//  FLTutorialView.m
//  Flamey
//
//  Created by Shane Rogers on 3/4/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialView.h"

@implementation FLTutorialView

NSString *const kCompleteTutorial = @"completeTuroial";

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)finishTutorial:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:kCompleteTutorial
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
