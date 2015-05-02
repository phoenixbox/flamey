//
//  FBLMembersStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLMembersStore.h"
#import "AFNetworking.h"
#import "FBLAppConstants.h"
#import "FBLMember.h"
#import "FBLMemberCollection.h"
#import "JSONModel.h"

#import "FBLHelpers.h"

// Libs
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FBLMembersStore

+ (FBLMembersStore *)sharedStore {
    static FBLMembersStore *membersStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        membersStore = [[FBLMembersStore alloc] init];
    });

    return membersStore;
}

- (void)refreshMembersWithCollection:(NSArray *)members {
    NSDictionary *membersDict = @{@"members": members};

    FBLMemberCollection *memberCollection = [[FBLMemberCollection alloc] initWithDictionary:membersDict error:nil];

    _members = memberCollection.members;
}

- (FBLMember *)find:(NSString *)memberId {
    for (FBLMember* member in _members) {
        if ([member.id isEqualToString:memberId]) {
            return member;
        }
    }

    return nil;
}

- (void)processMemberPhotos {
    for (FBLMember* member in _members) {
        if (!member.profileImage) {
            dispatch_queue_t concurrentQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);

            dispatch_async(concurrentQueue, ^{
                __block UIImage *image = nil;

                dispatch_sync(concurrentQueue, ^{
                    NSURL *url = [NSURL URLWithString:member.image32];
                    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
                    NSError *downloadError = nil;
                    NSData *imageData = [NSURLConnection sendSynchronousRequest:urlRequest
                                                              returningResponse:nil
                                                                          error:&downloadError];

                    if (downloadError == nil && imageData != nil){
                        image = [UIImage imageWithData:imageData];
                    } else if (downloadError != nil){
                        NSLog(@"Error happened = %@", downloadError); } else {
                            NSLog(@"No data could get downloaded from the URL.");
                        }
                });

                dispatch_sync(dispatch_get_main_queue(), ^{
                    if (image != nil){
                        member.profileImage = image;
                    } else {
                        NSLog(@"Member image not downloaded. Nothing to display.");
                    }
                });
            });
        }
    }
}

@end
