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