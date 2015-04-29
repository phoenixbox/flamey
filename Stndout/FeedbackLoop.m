//
//  FeedbackLoop.m
//  FeedbackLoop
//
//  Created by Shane Rogers on 4/26/15.
//  Copyright (c) 2015 FBL. All rights reserved.
//

#import "FeedbackLoop.h"

// Data Layer
#import "FBLAuthenticationStore.h"
#import "FBLAppConstants.h"

// Components
#import "FBLFeedbackTabBarController.h"
#import "FBLChatViewController.h"

static NSString * const kFeedbackTabBarController = @"FBLFeedbackTabBarController";

@interface FeedbackLoop ()
@property (nonatomic, strong) UIWindow *feedbackLoopWindow;
@end

@implementation FeedbackLoop

+ (FeedbackLoop *)sharedInstance {
    static dispatch_once_t once;
    static FeedbackLoop *feedbackLoop;

    dispatch_once(&once, ^ {
        feedbackLoop = [[self alloc] init];
    });

    return feedbackLoop;
}

+ (void)configureWithSlackToken:(NSString *)slackToken {
    FBLAuthenticationStore *store = [FBLAuthenticationStore sharedInstance];
    [store setSlackToken:slackToken];
}

+ (void)initWithAppId:(NSString *)appId {
    FBLAuthenticationStore *store = [FBLAuthenticationStore sharedInstance];
    [store setAppId:appId];
}

+ (void)setApiKey:(NSString *)apiKey forAppId:(NSString *)appId {
}

+ (void)registerUserWithEmail:(NSString *)userEmail {
    FBLAuthenticationStore *store = [FBLAuthenticationStore sharedInstance];
    [store setUserEmail:userEmail];
}

+ (void)presentChatChannel {
    FeedbackLoop *singleton = [self sharedInstance];
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    singleton.feedbackLoopWindow = [[UIWindow alloc]initWithFrame:screenBounds];
    [singleton.feedbackLoopWindow setWindowLevel:UIWindowLevelAlert];

    FBLChatViewController *chatViewController = [[FBLChatViewController alloc] init];

    [singleton.feedbackLoopWindow setRootViewController:chatViewController];
    [singleton.feedbackLoopWindow makeKeyAndVisible];
}

+ (void)presentConversationList {
    // Present the historical conversation thread
}


@end