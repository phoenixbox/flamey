//
//  FLPhotoStore.m
//  Flamey
//
//  Created by Shane Rogers on 1/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLPhotoStore.h"
#import <ObjectiveSugar/ObjectiveSugar.h>

@implementation FLPhotoStore

+ (FLPhotoStore *)sharedStore {
    static FLPhotoStore *photoStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        photoStore = [[FLPhotoStore alloc] init];
    });
    return photoStore;
}

- (void)addUniquePhoto:(FLPhoto *)photo {
    if(!self.allPhotos){
        self.allPhotos = [NSMutableArray new];
    }

    BOOL exists = NO;

    for (FLPhoto* object in self.allPhotos) {
        if ([object.id isEqualToNumber:photo.id]) {
            NSLog(@"exists");
            exists = YES;
        }
    }

    if (!exists) {
        [self.allPhotos addObject:photo];
    }
}

@end