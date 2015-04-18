//
//  FBLChannel.m
//  Stndout
//
//  Created by Shane Rogers on 4/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChannel.h"

@implementation FBLChannel

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"id": @"id",
                                                       @"name": @"name",
                                                       @"created": @"created",
                                                       @"last_ead": @"lastRead",
                                                       @"creator": @"creator",
                                                       @"members": @"members",
                                                       @"purpose.value": @"purpose",
                                                       @"latest": @"latest",
                                                       @"unread_count": @"unreadCount",
                                                       @"unread_count_display": @"unreadCountDisplay",
                                                       @"is_archived": @"isArchived",
                                                       @"is_general": @"isGeneral",
                                                       @"is_member": @"isMember"
                                                       }];
}

//{
//    "id": "C024BE91L",
//    "name": "fun",
//    "is_channel": "true",
//    "created": 1360782804,
//    "creator": "U024BE7LH",
//    "is_archived": false,
//    "is_general": false,
//
//    "members": [
//                "U024BE7LH",
//                …
//                ],
//
//    "topic": {
//        "value": "Fun times",
//        "creator": "U024BE7LV",
//        "last_set": 1369677212
//    },
//    "purpose": {
//        "value": "This channel is for fun",
//        "creator": "U024BE7LH",
//        "last_set": 1360782804
//    }
//
//    "is_member": true,
//
//    "last_read": "1401383885.000061",
//    "latest": { … }
//    "unread_count": 0,
//    "unread_count_display": 0
//}

@end
