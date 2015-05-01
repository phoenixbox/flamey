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
        [[FBLMembersStore sharedStore] processMemberPhotos];
        [[FBLChannelStore sharedStore] refreshChannelsWithCollection:[rtmResponse objectForKey:@"channels"]];

        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
    }];
}

- (void)slackOAuth:(void (^)(NSError *err))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSString *requestURL = [[FBLAuthenticationStore sharedInstance] channelForEmailRegUser];
    NSLog(@"Oauth request URL %@", requestURL);
    
    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // Restart: make the local request and parse the necessary information
        NSMutableDictionary *oauthRequest = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

        // There must be a better accessor pattern here
        NSDictionary *rtm = [oauthRequest objectForKey:@"rtm"];

        if (rtm && [rtm objectForKey:@"ok"]) {

            self.webhookUrl = [rtm objectForKey:@"url"];

            // Set the team on the team store
            NSDictionary *teamAttrs = [oauthRequest objectForKey:@"team"];
            FBLTeam *team = [[FBLTeam alloc] initWithDictionary:teamAttrs error:nil];
            [team buildToken];
            NSString *teamImage = [[[rtm objectForKey:@"team"] objectForKey:@"icon"] objectForKey:@"image_132"];
            [team setTeamImage:teamImage];
            [[FBLTeamStore sharedStore] setTeam:team];

            // Use the channel object
            _userChannelId = [[oauthRequest objectForKey:@"channel"] objectForKey:@"channel_id"];

            [[FBLMembersStore sharedStore] refreshMembersWithCollection:[rtm objectForKey:@"users"]];
            [[FBLMembersStore sharedStore] processMemberPhotos];
            [[FBLChannelStore sharedStore] refreshChannelsWithCollection:[rtm objectForKey:@"channels"]];
        } else {
            NSLog(@"RTM request error");
        }
        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
    }];
}

@end