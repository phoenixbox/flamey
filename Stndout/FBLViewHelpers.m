//
//  FBLViewHelpers.m
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLViewHelpers.h"

@implementation FBLViewHelpers

+ (void)setBaseButtonStyle:(UIButton *)button withColor:(UIColor *)color {
    // TODO Update for state variety
    button.layer.cornerRadius = 4;
    button.layer.borderWidth = 2;
    button.layer.borderColor = color.CGColor;
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTintColor:color];
}

+ (SIAlertView *)createAlertForError:(NSError *)error
        withTitle:(NSString *)title
       andMessage:(NSString *)message {
    // TODO: Should receive the class name for more instructive logging
    
    NSLog(@"Error: %@", error.localizedDescription);
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];

    [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

    [alertView addButtonWithTitle:@"Ok"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                          }];

    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

    return alertView;
}

@end
