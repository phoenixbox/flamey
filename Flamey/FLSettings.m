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
        [settings setNeedToLogin:YES];
    });
    return settings;
}

#pragma mark - Properties

static NSString *const kShouldSkipLoginKey = @"shouldSkipLogin";
static NSString *const kNeedToLogin = @"needToLogin";

- (BOOL)shouldSkipLogin
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldSkipLoginKey];
}


- (BOOL)needToLogin
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNeedToLogin];
}

- (void)setShouldSkipLogin:(BOOL)shouldSkipLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:shouldSkipLogin forKey:kShouldSkipLoginKey];
    [defaults synchronize];
}

- (void)setNeedToLogin:(BOOL)needToLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:needToLogin forKey:kNeedToLogin];
    [defaults synchronize];
}

@end
