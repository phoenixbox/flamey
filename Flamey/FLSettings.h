//
//  FLSettings.h
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FLUser.h"

@interface FLSettings : NSObject

+ (instancetype)defaultSettings;

@property (nonatomic, assign) BOOL shouldSkipLogin;
@property (nonatomic, assign) BOOL needToLogin;
@property (nonatomic, assign) BOOL seenTutorial;
@property (nonatomic, assign) BOOL uploadPermission;
@property (nonatomic, assign) BOOL understandAnnotation;
@property (nonatomic, strong) NSString *selectedPersona;
@property (nonatomic, strong) FLUser *user;

- (FLUser *)getUser;

@end