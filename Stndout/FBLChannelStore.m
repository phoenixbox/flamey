//
//  FBLSlackStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/15/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

// Libs
#import "AFNetworking.h"

// Data Layer
#import "FBLChannelStore.h"
#import "FBLChannelCollection.h"

// Constants
#import "FBLAppConstants.h"

@implementation FBLChannelStore

+ (FBLChannelStore *)sharedStore {
    static FBLChannelStore *channelStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        channelStore = [[FBLChannelStore alloc] init];
    });

    return channelStore;
}


//    Channels Join Error Description
//    --------------------------------------------------------------
//    channel_not_found:    Value passed for channel was invalid.
//    name_taken:           A channel cannot be created with the given name.
//    restricted_action:    A team preference prevents the authenticated user from creating channels.
//    no_channel:           Value passed for name was empty.
//    is_archived:          Channel has been archived.
//    not_authed:           No authentication token provided.
//    invalid_auth:         Invalid authentication token.
//    account_inactive:     Authentication token is for a deleted user or team.
//    user_is_bot:          This method cannot be called by a bot user.
//    user_is_restricted:   This method can

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


- (void)refreshChannelsWithCollection:(NSArray *)channels {
    NSDictionary *channelsDict = @{@"channels": channels};

    FBLChannelCollection *channelCollection = [[FBLChannelCollection alloc] initWithDictionary:channelsDict error:nil];

    [self addUniqueChannelsToStore:channelCollection.channels];
}

// TODO: Two operations predicated on unique should be merged?
- (void)addUniqueChannelsToStore:(NSMutableArray *)channels {
    for (FBLChannel *channel in channels) {
        [self addUniqueChannel:channel];
    }
}

- (void)addUniqueChannel:(FBLChannel *)channel {
    if(!_channels){
        _channels = [NSMutableArray new];
    }

    BOOL exists = NO;

    for (FBLChannel* model in _channels) {
        if ([model.id isEqualToString:channel.id]) {
            NSLog(@"Channel already exists");
            exists = YES;
        }
    }

    if (!exists) {
        [_channels addObject:channel];
    }
}

- (FBLChannel *)find:(NSString *)channelId {
    for (FBLChannel* channel in _channels) {
        if ([channel.id isEqualToString:channelId]) {
            return channel;
        }
    }
    
    return nil;
}

@end
