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

void FLErrorHandler(NSError *error)
{
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
                    NSLog(@"user cancelled login");
                    break;
                }
                default:{
                    alertTitle = @"Ooops";
                    alertMessage = @"Something went wrong, please try again :)";
                    NSLog(@"Unexpected error:%@", error);
                    break;
                }
            }
        }

        if (alertMessage) {
            [[[UIAlertView alloc] initWithTitle:alertTitle
                                        message:alertMessage
                                       delegate:nil
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil] show];
        }
    }
}

