//
//  FBLAuthenticationStore.h
//  Stndout
//
//  Created by Shane Rogers on 4/27/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBLAuthenticationStore : NSObject

@property (nonatomic, strong) NSString *slackToken;
@property (nonatomic, strong) NSString *feedbackLoopToken;
@property (nonatomic, strong) NSString *AppId;
@property (nonatomic, strong) NSString *userEmail;


+ (FBLAuthenticationStore *)sharedInstance;

- (NSString *)authenticateRequest:(NSString *)requestURL;
- (NSString *)oauthRequest:(NSString *)requestURL;
- (NSString *)oauthRequest:(NSString *)requestURL withURLSegment:(NSString *)urlSegment;

- (NSString *)authenticateRequest:(NSString *)requestURL withURLSegment:(NSString *)urlSegment;

- (NSString *)channelForEmailRegUser;

@end
