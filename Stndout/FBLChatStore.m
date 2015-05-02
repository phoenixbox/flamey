//
//  FBLMessageStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChatStore.h"

#import "FBLAppConstants.h"
#import "FBLAuthenticationStore.h"

// Libs
#import "AFNetworking.h"

@implementation FBLChatStore

+ (FBLChatStore *)sharedStore {
    static FBLChatStore *chatStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        chatStore = [[FBLChatStore alloc] init];
    });

    return chatStore;
}

//    Chat Error Description
//    --------------------------------------------------------------
//    channel_not_found: Value passed for channel was invalid.
//    not_in_channel: Cannot post user messages to a channel they are not in.
//    is_archived: Channel has been archived.
//    msg_too_long: Message text is too long
//    no_text: No message text provided
//    rate_limited: Application has posted too many messages, read the Rate Limit documentation for more information
//    not_authed: No authentication token provided.
//    invalid_auth: Invalid authentication token.
//    account_inactive: Authentication token is for a deleted user or team.

//    Chat Scheme
//    --------------------------------------------------------------
//{
//    "ok": true,
//    "ts": "1405895017.000506",
//    "channel": "C024BE91L",
//    "message": {
//        …
//    }
//}

- (void)sendSlackMessage:(NSString *)message toChannel:(FBLChannel *)channel withCompletion:(void (^)(FBLChat *chat, NSString *error))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        NSString *requestURL = [[FBLAuthenticationStore sharedInstance] oauthRequest:SLACK_API_BASE_URL withURLSegment:SLACK_API_MESSAGE_POST];
//    NSString *requestURL = authenticateRequestWithURLSegment(SLACK_API_BASE_URL, SLACK_API_MESSAGE_POST);

    // TODO: FBLUser Helpers: Fallback for when there is no user email etc.
//    NSString *messageParam = [NSString stringWithFormat:@"&text=%@",message];
//    requestURL = [requestURL stringByAppendingString:messageParam];
    NSString *channelIdParam = [NSString stringWithFormat:@"&channel=%@",channel.id];
    requestURL = [requestURL stringByAppendingString:channelIdParam];

    NSDictionary *textParams = @{@"text": message};

    [manager POST:requestURL parameters:textParams success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *sendMessageResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

        if ([sendMessageResponse objectForKey:@"ok"]) {

            FBLChat *chat = [[FBLChat alloc] initWithDictionary:[sendMessageResponse objectForKey:@"message"] error:nil];

            block(chat, nil);
        } else {
            NSString *errorType = [sendMessageResponse objectForKey:@"error"];

            block(nil, errorType);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        block(nil, error.localizedDescription);
    }];
}

- (void)fetchHistoryForChannel:(NSString *)channelId withCompletion:(void (^)(FBLChatCollection *chatCollection, NSString *))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSString *requestURL = [[FBLAuthenticationStore sharedInstance] oauthRequest:SLACK_API_BASE_URL withURLSegment:SLACK_API_CHANNEL_HISTORY];
    // TODO: FBLUser Helpers: Fallback for when there is no user email etc.

    NSString *channelIdParam = [NSString stringWithFormat:@"&channel=%@",channelId];
    requestURL = [requestURL stringByAppendingString:channelIdParam];

    [manager POST:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSMutableDictionary *sendMessageResponse = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:nil];

        if ([sendMessageResponse objectForKey:@"ok"]) {
            NSString *rawJSON = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

            FBLChatCollection *chatCollection = [[FBLChatCollection alloc] initWithString:rawJSON error:nil];

            block(chatCollection, nil);
        } else {
            NSString *errorType = [sendMessageResponse objectForKey:@"error"];

            block(nil, errorType);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {

        block(nil, error.localizedDescription);
    }];

}

@end
