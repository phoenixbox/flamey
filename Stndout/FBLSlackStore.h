//
//  FBLSlackStore.h
//  Stndout
//
//  Created by Shane Rogers on 4/19/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBLSlackStore : NSObject

@property (nonatomic, strong) NSString *webhookUrl;
@property (nonatomic, strong) NSString *userChannelId;

+ (FBLSlackStore *)sharedStore;

- (void)setupWebhook:(void (^)(NSError *err))block;

- (void)slackOAuth:(void (^)(NSError *err))block;

@end
