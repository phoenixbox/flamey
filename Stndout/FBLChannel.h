//
//  FBLChannel.h
//  Stndout
//
//  Created by Shane Rogers on 4/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"

@protocol FBLChannel @end

@interface FBLChannel : JSONModel

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *created;    // unix timestamp
@property (nonatomic, strong) NSString *lastRead;   // unix timestamp
@property (nonatomic, strong) NSString *creator;
@property (nonatomic, strong) NSArray *members;
@property (nonatomic, strong) NSString *purpose;    // purpose.value
@property (nonatomic, strong) NSDictionary *latest; // Latest Message
@property (nonatomic, strong) NSNumber *unreadCount;
@property (nonatomic, strong) NSNumber *unreadCountDisplay;
@property (nonatomic, assign) BOOL isArchived;
@property (nonatomic, assign) BOOL isGeneral;
@property (nonatomic, assign) BOOL isMember;

@end