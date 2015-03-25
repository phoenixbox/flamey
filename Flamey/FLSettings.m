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
static NSString *const kSeenTutorial = @"seenTutorial";
static NSString *const kSelectedPersonaKey = @"selectedPersona";
static NSString *const kUserKey = @"user";
static NSString *const kUploadPermission = @"uploadPermission";

- (BOOL)shouldSkipLogin
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kShouldSkipLoginKey];
}

- (BOOL)needToLogin
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kNeedToLogin];
}

- (BOOL)seenTutorial
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSeenTutorial];
}

- (BOOL)uploadPermission {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUploadPermission];
}

- (NSString *)selectedPersona
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSelectedPersonaKey];
}

- (FLUser *)getUser
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUserKey];
}

#pragma Override Property Setter

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

- (void)setSeenTutorial:(BOOL)seenTutorial {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:seenTutorial forKey:kSeenTutorial];
    [defaults synchronize];
}

- (void)setUploadPermission:(BOOL)uploadPermission {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:uploadPermission forKey:kUploadPermission];
    [defaults synchronize];
}

- (void)setSelectedPersona:(NSString *)selectedPersona {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:selectedPersona forKey:kSelectedPersonaKey];
    [defaults synchronize];
}

- (void)setuser:(FLUser *)user {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:user forKey:kUserKey];
    [defaults synchronize];
}

@end