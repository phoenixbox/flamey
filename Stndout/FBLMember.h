//
//  FBLMember.h
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol FBLMember @end

@interface FBLMember : JSONModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *slackName;
@property (nonatomic, strong) NSString *color;
// Profile
@property (nonatomic, strong) NSString *firstName; //Shane
@property (nonatomic, strong) NSString *lastName; //Rogers
@property (nonatomic, strong) NSString *realName; //Shane Rogers
@property (nonatomic, strong) NSString *realNameNormalized; //Shane Rogers
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *skype;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *image24;
@property (nonatomic, strong) NSString *image32;
@property (nonatomic, strong) NSString *image48;
@property (nonatomic, strong) NSString *image72;
@property (nonatomic, strong) NSString *image192;

@property (nonatomic, strong) UIImage *profileImage;

@property (nonatomic, strong) NSString *status;
@property (nonatomic, strong) NSString *tz;
@property (nonatomic, strong) NSString *tzLabel;
@property (nonatomic, strong) NSString *tzOffset;

@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) BOOL isPrimaryOwner;
@property (nonatomic, assign) BOOL isRestricted;
@property (nonatomic, assign) BOOL isUltraRestricted;
@property (nonatomic, assign) BOOL has2fa;
@property (nonatomic, assign) BOOL hasFiles;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, assign) BOOL isBot;

@end


// Slack Member.list schema
//{
//    color = 9f69e7;
//    deleted = 0;
//    "has_2fa" = 0;
//    "has_files" = 1;
//    id = U04AP0LL0;
//    "is_admin" = 1;
//    "is_bot" = 0;
//    "is_owner" = 1;
//    "is_primary_owner" = 1;
//    "is_restricted" = 0;
//    "is_ultra_restricted" = 0;
//    name = shanerogers; -- client-side convert to slackName
//    profile =     {
//        email = "shane@email.com";
//        "first_name" = Shane;
//        "image_192" = "https://secure.gravatar.com/..";
//        "image_24" = "https://secure.gravatar.com/..";
//        "image_32" = "https://secure.gravatar.com/..";
//        "image_48" = "https://secure.gravatar.com/..";
//        "image_72" = "https://secure.gravatar.com/..";
//        "last_name" = Rogers;
//        "real_name" = "Shane Rogers";
//        "real_name_normalized" = "Shane Rogers";
//        title = Software;
//    };
//    "real_name" = "Shane Rogers";
//    status = "<null>";
//    tz = "America/Los_Angeles";
//    "tz_label" = "Pacific Daylight Time";
//    "tz_offset" = "-25200";
//}

