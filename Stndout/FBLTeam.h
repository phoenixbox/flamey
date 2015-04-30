//
//  FBLTeam.h
//  Stndout
//
//  Created by Shane Rogers on 4/28/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol FBLTeam @end

@interface FBLTeam : JSONModel

@property (nonatomic, strong) NSString *guid;
@property (nonatomic, strong) NSString *tokenizer;
@property (nonatomic, strong) NSString *slackName;
@property (nonatomic, strong) NSString *slackTeamId;
@property (nonatomic, strong) NSString *tokenS;
@property (nonatomic, strong) NSString *tokenL;
@property (nonatomic, strong) NSString *tokenA;
@property (nonatomic, strong) NSString *tokenC;
@property (nonatomic, strong) NSString *tokenK;

@property (nonatomic, strong) NSString *teamImage;
// Aggreagate Token - rethink the obfuscation into alpha-keys
@property (nonatomic, strong) NSString *slackToken;

- (void)buildToken;

@end