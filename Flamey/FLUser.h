//
//  FLUser.h
//  Flamey
//
//  Created by Shane Rogers on 3/21/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol FLUser @end

@interface FLUser : JSONModel

@property (nonatomic, strong) NSString *gender;
@property (nonatomic, strong) NSString *locale;
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *updated_time;
@property (nonatomic, strong) NSString *last_name;
@property (nonatomic, strong) NSString *timezone;
@property (nonatomic, strong) NSString *email;
@property (nonatomic, strong) NSString *link;
@property (nonatomic, assign) BOOL verified;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *first_name;

- (BOOL)isMale;

- (BOOL)isFemale;

@end
