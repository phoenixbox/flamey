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
        [settings setSeenTutorial:NO];
    });
    return settings;
}

#pragma mark - Properties

static NSString *const kSession = @"session";
static NSString *const kSeenTutorial = @"seenTutorial";
static NSString *const kSelectedPersonaKey = @"selectedPersona";
static NSString *const kUserKey = @"user";
static NSString *const kUploadPermission = @"uploadPermission";
static NSString *const kUnderstandAnnotation = @"understandAnnotation";

- (BOOL)seenTutorial
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kSeenTutorial];
}

- (BOOL)uploadPermission {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUploadPermission];
}

- (BOOL)understandAnnotation {
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

- (FBSession *)getSession
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:kSession];
}

#pragma Override Property Setter

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

- (void)setUnderstandAnnotation:(BOOL)understandAnnotation {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:understandAnnotation forKey:kUnderstandAnnotation];
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

- (void)setSession:(FBSession *)session
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:session forKey:kSession];
    [defaults synchronize];
}

@end