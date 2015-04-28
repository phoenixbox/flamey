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

static NSString * const kFeedbackTabBarController = @"FBLFeedbackTabBarController";

@interface FeedbackLoop ()
@property (nonatomic, strong) UIWindow *feedbackLoopWindow;
@property (nonatomic, strong) NSString *slackToken;
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
    FeedbackLoop *store = [FeedbackLoop sharedInstance];
    [store setSlackToken:slackToken];
}

+ (void)setApiKey:(NSString *)apiKey forAppId:(NSString *)appId {
}

+ (void)presentChatChannel {
    FeedbackLoop *singleton = [self sharedInstance];
    singleton.feedbackLoopWindow = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    [singleton.feedbackLoopWindow setWindowLevel:UIWindowLevelAlert];

    FBLFeedbackTabBarController *tabBarController = [[FBLFeedbackTabBarController alloc] initWithNibName:kFeedbackTabBarController bundle:nil];
    tabBarController.modalPresentationStyle = UIModalTransitionStyleFlipHorizontal;

    // Can I just cast this to a UIView
    [singleton.feedbackLoopWindow addSubview:(UIView *)tabBarController];

    [singleton.feedbackLoopWindow makeKeyAndVisible];
}

+ (void)presentConversationList {
    // Present the historical conversation thread
}


@end