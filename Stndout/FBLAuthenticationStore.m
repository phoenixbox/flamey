//
//  FBLAuthenticationStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/27/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLAuthenticationStore.h"

// Constants
#import "FBLAppConstants.h"

@implementation FBLAuthenticationStore

+ (FBLAuthenticationStore *)sharedInstance {
    static FBLAuthenticationStore *authStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        authStore = [[FBLAuthenticationStore alloc] init];
    });

    return authStore;
}

- (NSString *)authenticateRequest:(NSString *)requestURL {
    requestURL = [requestURL stringByAppendingString:(@"?token=")];
    requestURL = [requestURL stringByAppendingString:self.slackToken];

    return requestURL;
}

- (NSString *)authenticateRequest:(NSString *)requestURL withURLSegment:(NSString *)urlSegment {
    if (urlSegment) {
        requestURL = [requestURL stringByAppendingString:urlSegment];
    }

    return [self authenticateRequest:requestURL];
}

- (NSString *)channelForEmailRegUser {
    //    let url = `${teamUrl}${user.app_id}.json?email=${user.email}&user_id=${user.user_id}`;
//    NSString *teamUrl = [NSString stringWithFormat:@"%@%@%@/%@%@", DEV_API_BASE_URL];

    NSString *base = DEV_API_BASE_URL;
    NSString *requestURL = [base stringByAppendingString:FBL_TEAMS_URI];
    requestURL = [NSString stringWithFormat:@"%@/%@%@", requestURL, self.AppId,@".json?"];
//    requestURL = [requestURL stringByAppendingString:@".json?"];

    requestURL = [NSString stringWithFormat:@"%@email=%@", requestURL, self.userEmail];

    return requestURL;
}


@end
