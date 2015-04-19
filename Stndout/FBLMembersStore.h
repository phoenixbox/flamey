//
//  FBLMembersStore.h
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLMember.h"

@interface FBLMembersStore : NSObject

@property (nonatomic, strong) NSMutableArray *members;

+ (FBLMembersStore *)sharedStore;

- (void)fetchMembersWithCompletion:(void (^)(NSError *error))block;

- (void)refreshMembersWithCollection:(NSArray *)members;

- (FBLMember *)find:(NSString *)memberId;

@end
