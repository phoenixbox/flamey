//
//  FeedbackLoop.h
//  Stndout
//
//  Created by Shane Rogers on 4/27/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedbackLoop : NSObject

+ (void)configureWithSlackToken:(NSString *)slackToken;

+ (void)setApiKey:(NSString *)apiKey forAppId:(NSString *)appId;

+ (void)registerUserWithEmail:(NSString *)userEmail;

+ (void)initWithAppId:(NSString *)appId;

+ (void)presentChatChannel;

@end
