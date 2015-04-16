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

#import <Parse/Parse.h>

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

        [self addUniqueMembersToParse:memberCollection.members];
        self.members = memberCollection.members;

        // create unique member records

        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
    }];
}

- (void)addUniqueMembersToParse:(NSMutableArray *)members {
    for(FBLMember *member in members) {

        // Find or create a member
        PFQuery *query = [PFQuery queryWithClassName:PF_MEMBER_CLASS_NAME];
        [query whereKey:PF_MEMBER_SLACKID equalTo:member.id];
        NSArray *ids = [query findObjects];

        if ([ids count] == 0) {
            PFObject *parseMemmber = [[PFObject alloc] initWithClassName:PF_MEMBER_CLASS_NAME];

            parseMemmber[PF_MEMBER_EMAIL] = member.email;
            parseMemmber[PF_MEMBER_SLACKNAME] = member.slackName;
            parseMemmber[PF_MEMBER_SLACKID] = member.id;
            parseMemmber[PF_MEMBER_REALNAME] = member.realName;
            parseMemmber[PF_CUSTOMER_PICTURE] = member.image72;
            parseMemmber[PF_MEMBER_TITLE] = member.title;

            [parseMemmber saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
             {
                 if (error == nil)
                 {
                     NSLog(@"%@ ERROR: Created Member. %@", NSStringFromClass([self class]), member.slackName);
                 }
                 else
                 {
                     NSLog(@"%@ ERROR: Network Error. %@",NSStringFromClass([self class]), error.localizedDescription);
                 }
             }];
        }
    }
}

@end
