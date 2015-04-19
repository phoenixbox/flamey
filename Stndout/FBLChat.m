//
//  FBLMessage.m
//  Stndout
//
//  Created by Shane Rogers on 4/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChat.h"

@implementation FBLChat

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"text": @"text",
                                                       @"username": @"username",
                                                       @"user": @"user",
                                                       @"type": @"type",
                                                       @"sub_type": @"subtype",
                                                       @"ts": @"ts"
                                                       }];
}

@end
