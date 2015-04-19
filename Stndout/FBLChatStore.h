//
//  FBLMessageStore.h
//  Stndout
//
//  Created by Shane Rogers on 4/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLChannel.h"
#import "FBLChatCollection.h"
#import "FBLChat.h"

@interface FBLChatStore : NSObject

+ (FBLChatStore *)sharedStore;

- (void)sendSlackMessage:(NSString *)message toChannel:(FBLChannel *)channel withCompletion:(void (^)(FBLChat *chat, NSString *))block;

- (void)fetchHistoryForChannel:(NSString *)channelId withCompletion:(void (^)(FBLChatCollection *chatCollection, NSString *))block;

@end
