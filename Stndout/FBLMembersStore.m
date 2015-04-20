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

#import "FBLHelpers.h"

// Libs
#import <Parse/Parse.h>
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

- (void)fetchMembersWithCompletion:(void (^)(NSError *err))block {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];

    NSString *requestURL = authenticateRequestWithURLSegment(SLACK_API_BASE_URL, SLACK_MEMBERS_URI);

    [manager GET:requestURL parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *rawJSON = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        FBLMemberCollection *memberCollection = [[FBLMemberCollection alloc] initWithString:rawJSON error:nil];

        [self addUniqueMembersToParse:memberCollection.members];

        _members = memberCollection.members;

        block(nil);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        block(error);
    }];
}

- (void)refreshMembersWithCollection:(NSArray *)members {
    NSDictionary *membersDict = @{@"members": members};

    FBLMemberCollection *memberCollection = [[FBLMemberCollection alloc] initWithDictionary:membersDict error:nil];

    [self addUniqueMembersToParse:memberCollection.members];

    _members = memberCollection.members;
}

- (void)addUniqueMembersToParse:(NSMutableArray *)members {
    for(FBLMember *member in members) {

        // Find or create a member
        PFQuery *query = [PFQuery queryWithClassName:PF_MEMBER_CLASS_NAME];
        [query whereKey:PF_MEMBER_SLACKID equalTo:member.id];
        NSArray *members = [query findObjects];

        if ([members count] == 0) {
            NSString *requestURL = member.image192;

            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:requestURL]
                                  options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                     // progression tracking code
                                 }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    if (image) {
                                        UIImage *picture = ResizeImage(image, 280, 280);
                                        UIImage *thumbnail = ResizeImage(image, 60, 60);

                                        PFObject *parseMemmber = [[PFObject alloc] initWithClassName:PF_MEMBER_CLASS_NAME];

                                        PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
                                        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                         {
                                             if (error != nil) {
                                                 NSLog(@"Something went wrong saving the members picture");
                                             };
                                         }];
                                        PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
                                        [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
                                         {
                                             if (error != nil) {
                                                 NSLog(@"Something went wrong saving the members fileThumbnail");
                                             }
                                         }];

                                        parseMemmber[PF_MEMBER_EMAIL] = member.email ? : FBL_DEFAULT_EMAIL;
                                        parseMemmber[PF_MEMBER_SLACKNAME] = member.slackName;
                                        parseMemmber[PF_MEMBER_SLACKID] = member.id;
                                        parseMemmber[PF_MEMBER_REALNAME] = member.realName;
                                        parseMemmber[PF_MEMBER_IMAGE_URL] = member.image192;
                                        parseMemmber[PF_MEMBER_TITLE] = member.title ? : FBL_DEFAULT_TITLE;
                                        parseMemmber[PF_MEMBER_PICTURE] = filePicture;
                                        parseMemmber[PF_MEMBER_THUMBNAIL] = fileThumbnail;
                                        
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
                                }];
            }
    }
}

- (FBLMember *)find:(NSString *)memberId {
    for (FBLMember* member in _members) {
        if ([member.id isEqualToString:memberId]) {
            return member;
        }
    }

    return nil;
}

@end
