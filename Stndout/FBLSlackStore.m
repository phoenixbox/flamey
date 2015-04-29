//
//  FBLSlackStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/19/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLSlackStore.h"

// Data Layer
#import "FBLAuthenticationStore.h"
#import "FBLMembersStore.h"
#import "FBLChannelStore.h"
#import "FBLTeam.h"
#import "FBLTeamStore.h"

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

    NSString *requestURL = [[FBLAuthenticationStore sharedInstance ]authenticateRequest:SLACK_API_BASE_URL withURLSegment:SLACK_API_RTM_START];

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

- (void)requestWebhookFromServer:(void (^)(NSError *err))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSString *requestURL = [[FBLAuthenticationStore sharedInstance] channelForEmailRegUser];

    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Restart: make the local request and parse the necessary information
        NSMutableDictionary *serverAuth = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

        if ([serverAuth objectForKey:@"ok"]) {

            self.webhookUrl = [serverAuth objectForKey:@"url"];

            // Set the team on the team store
            FBLTeam *team = [FBLTeam alloc] initWithDictionary:serverAuth objectForKey:@"team"] error:nil];
            [[FBLTeamStore sharedStore] setTeam:team]
        }

        // Once get the team token back then can handle my own networking layer


//        setTeam(opts.team);
//
//        let {messages, channel_id} =  opts.channel;
//        setChannel(channel_id);
//        setItems(messages);
//
//        let {url, users, self} = opts.rtm;
//        createConnection(url);
//        setUsers(users);
//        setSelf(self);
//        MessageStore.emitChange();


        [[FBLMembersStore sharedStore] refreshMembersWithCollection:[rtmResponse objectForKey:@"users"]];
        [[FBLChannelStore sharedStore] refreshChannelsWithCollection:[rtmResponse objectForKey:@"channels"]];

        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
    }];
}

@end
