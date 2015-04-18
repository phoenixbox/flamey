//
//  FBLSlackStore.h
//  Stndout
//
//  Created by Shane Rogers on 4/15/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FBLSlackStore : NSObject

+ (FBLSlackStore *)sharedStore;

- (void)createAnyoneSlackChannel:(void (^)(NSString *channelId, NSString *createAnyoneError))block;

@end
