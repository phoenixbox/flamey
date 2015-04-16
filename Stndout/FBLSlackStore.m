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

- (void)createAnyoneSlackChannel:(void (^)(NSString *channelId, NSError *error))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    NSString *requestURL = authenticateRequestWithURLSegment(SLACK_API_BASE_URL, SLACK_API_CHANNEL_JOIN);
    PFUser *currentUser = [PFUser currentUser];
    NSString *queryStringParams = [NSString stringWithFormat:@"&name=%@",currentUser.email];
    [requestURL stringByAppendingString:queryStringParams];


    void(^currentUserChannelBlock)(NSError *err)=^(NSError *error){
        [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSString *string = [NSString new];

            NSString *rawJSON = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

            NSMutableDictionary *createChannelResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];


            block(string, nil);
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            block(nil, error);
        }];
    };

    [self _findOrCreateCurrentUserChannel:currentUserChannelBlock];
}

- (void)_findOrCreateCurrentUserChannel:(void (^)(NSError *error))block {
    PFUser *currentUser = [PFUser currentUser];
    // Find or create
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
    }];

}

@end
