//
//  FLSettings.h
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

// Data Layer
#import "FLUser.h"

// Libs
#import <FacebookSDK/FacebookSDK.h>

@interface FLSettings : NSObject

+ (instancetype)defaultSettings;

@property (nonatomic, assign) BOOL seenTutorial;
@property (nonatomic, assign) BOOL uploadPermission;
@property (nonatomic, assign) BOOL understandAnnotation;
@property (nonatomic, strong) NSString *selectedPersona;
@property (nonatomic, strong) FLUser *user;
@property (nonatomic, assign) FBSession *session;

- (FLUser *)getUser;

- (FBSession *)getSession;

@end