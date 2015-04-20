//
//  FBLSlackStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/19/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLSlackStore.h"

// Data Layer
#import "FBLAuth.h"
#import "FBLMembersStore.h"
#import "FBLChannelStore.h"

// Constants
#import "FBLAppConstants.h"

// Libs
#import "AFNetworking.h"

@implementation FBLSlackStore

+ (FBLSlackStore *)sharedStore {
    static FBLSlackStore *slackStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        slackStore = [[FBLSlackStore alloc] init];
    });

    return slackStore;
}

- (void)setupWebhook:(void (^)(NSError *err))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSString *requestURL = authenticateRequestWithURLSegment(SLACK_API_BASE_URL, SLACK_API_RTM_START);

    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *rtmResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];
        
        if ([rtmResponse objectForKey:@"ok"]) {
            self.webhookUrl = [rtmResponse objectForKey:@"url"];
        }

        [[FBLMembersStore sharedStore] refreshMembersWithCollection:[rtmResponse objectForKey:@"users"]];
        [[FBLChannelStore sharedStore] refreshChannelsWithCollection:[rtmResponse objectForKey:@"channels"]];

        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
    }];

}

@end
