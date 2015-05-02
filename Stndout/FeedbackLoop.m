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
#import "FBLChatViewController.h"

static NSString * const kFeedbackTabBarController = @"FBLFeedbackTabBarController";

@interface FeedbackLoop ()
@property (nonatomic, strong) UIWindow *feedbackLoopWindow;
@property (nonatomic, strong) FBLChatViewController *chatViewController;
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
    if (singleton.feedbackLoopWindow && singleton.feedbackLoopWindow.hidden) {
        [singleton.feedbackLoopWindow setHidden:NO];
    }

    CGRect screenBounds = [[UIScreen mainScreen] bounds];

    singleton.feedbackLoopWindow = [[UIWindow alloc]initWithFrame:screenBounds];
    [singleton.feedbackLoopWindow setWindowLevel:UIWindowLevelAlert];

    void (^popWindow)() = ^void() {
        [self popWindow];
    };

    singleton.chatViewController = [[FBLChatViewController alloc] init];
    singleton.chatViewController.popWindow = popWindow;

    [singleton.feedbackLoopWindow setRootViewController:singleton.chatViewController];
    [singleton.feedbackLoopWindow makeKeyAndVisible];
}

+ (void)popWindow {
    FeedbackLoop *singleton = [self sharedInstance];
    NSLog(@"Remove FeedbackLoop Window");
    singleton.feedbackLoopWindow = nil;
}

@end