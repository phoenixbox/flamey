//
//  FBLMember.m
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLMember.h"

@implementation FBLMember

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"id",
                                                       @"name": @"slackName",
                                                       @"color": @"color",
                                                       @"profile.email": @"email",
                                                       @"profile.first_name": @"firstName",
                                                       @"profile.image_24": @"image24",
                                                       @"profile.image_32": @"image32",
                                                       @"profile.image_48": @"image48",
                                                       @"profile.image_72": @"image72",
                                                       @"profile.image_192": @"image192",
                                                       @"profile.last_name": @"lastName",
                                                       @"profile.real_name": @"realName",
                                                       @"profile.real_name_normalized": @"realNameNormalized",
                                                       @"profile.skype": @"skype",
                                                       @"profile.phone": @"phone",
                                                       @"profile.title": @"title",
                                                       @"status": @"status",
                                                       @"tz": @"tz",
                                                       @"tz_label": @"tzLabel",
                                                       @"tz_offset": @"tzOffset",
                                                       @"is_admin": @"isAdmin",
                                                       @"is_owner": @"isOwner",
                                                       @"is_primary_owner": @"isPrimaryOwner",
                                                       @"is_ultra_restricted": @"isUltraRestricted",
                                                       @"is_restricted": @"isRestricted",
                                                       @"has_2fa": @"has2fa",
                                                       @"has_files": @"hasFiles",
                                                       @"deleted": @"deleted",
                                                       @"is_bot": @"isBot",
                                                       }];
}

@end
