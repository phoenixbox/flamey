//
//  FLErrorHandler.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLErrorHandler.h"

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>
#import <SIAlertView/SIAlertView.h>
#import "Mixpanel.h"

void FLErrorHandler(NSError *error) {
    if (error != nil) {
        NSString *alertMessage;
        NSString *alertTitle;

        if ([FBErrorUtility shouldNotifyUserForError:error]) {

            alertTitle = @"Something Went Wrong";
            alertMessage = [FBErrorUtility userMessageForError:error];
        } else {
            switch ([FBErrorUtility errorCategoryForError:error]) {
                case FBErrorCategoryAuthenticationReopenSession:{
                    alertTitle = @"Session Error";
                    alertMessage = @"Your current session is no longer valid. Please log in again.";
                    break;
                }
                case FBErrorCategoryUserCancelled:{
                    alertTitle = @"Ooops";
                    alertMessage = @"You cancelled login, please try again :)";
                    break;
                }
                default:{
                    alertTitle = @"Ooops";
                    alertMessage = @"Something went wrong, please try again :)";
                    break;
                }
            }
        }

        if (alertMessage) {
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:alertTitle andMessage:alertMessage];

            [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
            [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
            [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

            [alertView addButtonWithTitle:@"Ok"
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alert) {
                                  }];


            alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
            
            [alertView show];
        }
    }
}

