//
//  FLSettings.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLSettings.h"

@implementation FLSettings

+ (instancetype)defaultSettings
{
    static FLSettings *settings = nil;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        settings = [[self alloc] init];
    });
    return settings;
}

#pragma mark - Properties

static NSString *const kShouldSkipLoginKey = @"shouldSkipLogin";

- (BOOL)shouldSkipLogin
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldSkipLoginKey];
}

- (void)setShouldSkipLogin:(BOOL)shouldSkipLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:shouldSkipLogin forKey:kShouldSkipLoginKey];
    [defaults synchronize];
}


@end
