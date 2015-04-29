//
//  FBLTeam.m
//  Stndout
//
//  Created by Shane Rogers on 4/28/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLTeam.h"

@implementation FBLTeam

+(BOOL)propertyIsOptional:(NSString*)propertyName
{
    return YES;
}

+(JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"token": @"token"}];
}

@end
