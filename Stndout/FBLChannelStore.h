//
//  FBLSlackStore.h
//  Stndout
//
//  Created by Shane Rogers on 4/15/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLChannel.h"

@interface FBLChannelStore : NSObject

@property (nonatomic, strong) NSMutableArray *channels;

+ (FBLChannelStore *)sharedStore;

- (void)refreshChannelsWithCollection:(NSArray *)channels;

- (FBLChannel *)find:(NSString *)channelId;


@end
