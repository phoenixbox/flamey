//
//  FBLTeamStore.m
//  Stndout
//
//  Created by Shane Rogers on 4/28/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLTeamStore.h"

@implementation FBLTeamStore

+ (FBLTeamStore *)sharedStore {
    static FBLTeamStore *teamStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        teamStore = [[FBLTeamStore alloc] init];
    });

    return teamStore;
}

@end