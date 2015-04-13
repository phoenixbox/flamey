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
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL deleted;
@property (nonatomic, strong) NSString *color;
// Profile
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic, strong) NSString *realName;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *skype;
@property (nonatomic, strong) NSString *phone;
@property (nonatomic, strong) NSString *image24;
@property (nonatomic, strong) NSString *image32;
@property (nonatomic, strong) NSString *image48;
@property (nonatomic, strong) NSString *image72;
@property (nonatomic, strong) NSString *image192;

@property (nonatomic, assign) BOOL isAdmin;
@property (nonatomic, assign) BOOL isOwner;
@property (nonatomic, assign) BOOL has2fa;
@property (nonatomic, assign) BOOL hasFiles;

@end


// Slack Member.list schema
//"id": "U023BECGF",
//"name": "bobby",
//"deleted": false,
//"color": "9f69e7",
//"profile": {
//    "first_name": "Bobby",
//    "last_name": "Tables",
//    "real_name": "Bobby Tables",
//    "email": "bobby@slack.com",
//    "skype": "my-skype-name",
//    "phone": "+1 (123) 456 7890",
//    "image_24": "https:\/\/...",
//    "image_32": "https:\/\/...",
//    "image_48": "https:\/\/...",
//    "image_72": "https:\/\/...",
//    "image_192": "https:\/\/..."
//},
//"is_admin": true,
//"is_owner": true,
//"has_2fa": false,
//"has_files": true
