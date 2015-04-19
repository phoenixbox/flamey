//
//  FBLChatCollection.h
//  Stndout
//
//  Created by Shane Rogers on 4/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JSONModel.h"
#import "FBLChat.h"

@interface FBLChatCollection : JSONModel

@property (strong, nonatomic) NSMutableArray<FBLChat> *messages;

@end
