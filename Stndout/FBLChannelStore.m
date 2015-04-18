//
//  FBLSlackStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/15/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLSlackStore.h"

#import "FBLAuth.h"
#import "AFNetworking.h"

// Data Layer
#import <Parse/Parse.h>

// Constants
#import "FBLAppConstants.h"

@implementation FBLSlackStore

+ (FBLSlackStore *)sharedStore {
    static FBLSlackStore *slackStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        slackStore = [[FBLSlackStore alloc] init];
    });

    return slackStore;
}

- (void)createAnyoneSlackChannel:(void (^)(NSString *channelId, NSString *createAnyoneError))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *requestURL = authenticateRequestWithURLSegment(SLACK_API_BASE_URL, SLACK_API_CHANNEL_JOIN);
    PFUser *currentUser = [PFUser currentUser];
    NSString *queryStringParams = [NSString stringWithFormat:@"&name=%@",currentUser.email];
    [requestURL stringByAppendingString:queryStringParams];


    void(^currentUserChannelBlock)(NSString *findOrCreateError)=^(NSString *findOrCreateError) {
        if(!findOrCreateError) {
            [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
                NSString *string = [NSString new];

                block(string, nil);
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

                block(nil, error.localizedDescription);
            }];
        } else {
            block(nil, findOrCreateError);
        }
    };

    [self _findOrCreateCurrentUserChannel:currentUserChannelBlock];
}

- (void)_findOrCreateCurrentUserChannel:(void (^)(NSString *error))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *requestURL = authenticateRequestWithURLSegment(SLACK_API_BASE_URL, SLACK_API_CHANNEL_CREATE);
    PFUser *currentUser = [PFUser currentUser];
    NSString *queryStringParams = [NSString stringWithFormat:@"&name=%@",currentUser.email];
    [requestURL stringByAppendingString:queryStringParams];

    // Create the

    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {

        NSString *rawJSON = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        NSMutableDictionary *createChannelResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

        if ([createChannelResponse objectForKey:@"error"]) {
            NSString *errorType = [createChannelResponse objectForKey:@"error"];

            block(errorType);
        } else {
            // create a channel model

            // add it to the channel store

            // Pass the channel back
            block(nil);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error.localizedDescription);
    }];
}

//  Create Errors
//  ----------------------------------------------------------------
//  name_taken:           A channel cannot be created with the given name.
//  restricted_action:    A team preference prevents the authenticated user from creating channels.
//  no_channel;           Value passed for name was empty.
//  not_authed:           No authentication token provided.
//  invalid_auth:         Invalid authentication token.
//  account_inactive:     Authentication token is for a deleted user or team.
//  user_is_bot:          This method cannot be called by a bot user.
//  user_is_restricted:   This method cannot be called by a restricted user or single c

// Channel Schema
//{
//    "ok": true,
//    "channel": {
//        "id": "C024BE91L",
//        "name": "fun",
//        "created": 1360782804,
//        "creator": "U024BE7LH",
//        "is_archived": false,
//        "is_member": true,
//        "is_general": false,
//        "last_read": "0000000000.000000",
//        "latest": null,
//        "unread_count": 0,
//        "unread_count_display": 0,
//        "members": [ … ],
//        "topic": { … },
//        "purpose": { … }
//    }
//}


@end
