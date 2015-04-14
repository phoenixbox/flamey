//
//  FBLMembersStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLMembersStore.h"
#import "FBLAuth.h"
#import "AFNetworking.h"
#import "FBLAppConstants.h"
#import "FBLMember.h"
#import "FBLMemberCollection.h"
#import "JSONModel.h"

@implementation FBLMembersStore

+ (FBLMembersStore *)sharedStore {
    static FBLMembersStore *membersStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        membersStore = [[FBLMembersStore alloc] init];
    });

    return membersStore;
}

- (void)fetchMembersWithCompletion:(void (^)(NSError *err))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSString *requestURL = authenticateRequestWithURLSegment(SLACK_API_BASE_URL, SLACK_MEMBERS_URI);

    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rawJSON = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        FBLMemberCollection *memberCollection = [[FBLMemberCollection alloc] initWithString:rawJSON error:nil];
        self.members = memberCollection.members;

        // create unique member records

        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
    }];
}

@end
