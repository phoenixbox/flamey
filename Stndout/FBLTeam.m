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
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                       @"guid": @"guid",
                                                       @"tokenizer": @"tokenizer",
                                                       @"slack_team": @"slackTeam",
                                                       @"slack_team_id": @"slackTeamId",                                                       
                                                       @"token.s": @"tokenS",
                                                       @"token.l": @"tokenL",
                                                       @"token.a": @"tokenA",
                                                       @"token.c": @"tokenC",
                                                       @"token.k": @"tokenK"
                                                       }];
}

- (void)buildToken {
    NSString *aggregateToken = [NSString stringWithFormat:@"%@-%@-%@-%@-%@", _tokenS,_tokenL, _tokenA, _tokenC, _tokenK];
    _slackToken = aggregateToken;
}

@end
