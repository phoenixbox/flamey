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

@property (nonatomic, strong) NSString *token;

@end