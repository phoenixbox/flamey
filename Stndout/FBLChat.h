//
//  FBLMessage.h
//  Stndout
//
//  Created by Shane Rogers on 4/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol FBLChat @end

@interface FBLChat : JSONModel

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *user;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *sub_type;
@property (nonatomic, strong) NSString *ts;
@property (nonatomic, strong) NSArray *attachments;



@end
