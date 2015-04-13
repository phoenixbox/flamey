//
//  FBLMembersCollection.h
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLMember.h"
#import "JSONModel.h"

@interface FBLMemberCollection : JSONModel

@property (strong, nonatomic) NSMutableArray<FBLMember> *members;

@end