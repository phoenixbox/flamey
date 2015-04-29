//
//  FBLTeamStore.h
//  Stndout
//
//  Created by Shane Rogers on 4/28/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLTeam.h"

@interface FBLTeamStore : NSObject

@property (nonatomic, strong) FBLTeam *team;

+ (FBLTeamStore *)sharedStore;

@end
