//
//  FLSettings.h
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLSettings : NSObject

+ (instancetype)defaultSettings;

@property (nonatomic, assign) BOOL shouldSkipLogin;

@end