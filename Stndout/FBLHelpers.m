//
//  FBLHelpers.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "FBLHelpers.h"

void LoginUser(id target)
{
    NSLog(@"Require idea of a user store");
}

void PostNotification(NSString *notification)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}

NSString* TimeElapsed(NSTimeInterval seconds)
{
    NSString *elapsed;
    if (seconds < 60)
    {
        elapsed = @"Just now";
    }
    else if (seconds < 60 * 60)
    {
        int minutes = (int) (seconds / 60);
        elapsed = [NSString stringWithFormat:@"%d %@", minutes, (minutes > 1) ? @"mins" : @"min"];
    }
    else if (seconds < 24 * 60 * 60)
    {
        int hours = (int) (seconds / (60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", hours, (hours > 1) ? @"hours" : @"hour"];
    }
    else
    {
        int days = (int) (seconds / (24 * 60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", days, (days > 1) ? @"days" : @"day"];
    }
    
    return elapsed;
}