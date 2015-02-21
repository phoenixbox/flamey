//
//  FLProcessedImagesStore.m
//  Flamey
//
//  Created by Shane Rogers on 2/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLProcessedImagesStore.h"

@implementation FLProcessedImagesStore

+ (FLProcessedImagesStore *)sharedStore {
    static FLProcessedImagesStore *processedPhotoStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        processedPhotoStore = [[FLProcessedImagesStore alloc] init];
    });

    return processedPhotoStore;
}

- (void)addUniquePhoto:(FLPhoto *)photo {
    if(!self.allPhotos){
        self.allProcessedPhotos = [NSMutableArray new];
    }

    BOOL exists = NO;

    for (FLPhoto* object in self.allPhotos) {
        if (object.id == photo.id) {
            NSLog(@"exists");
            exists = YES;
        }
    }

    if (!exists) {
        [self.allPhotos addObject:photo];
    }
}

- (NSMutableArray *)allPhotos {
    return self.allProcessedPhotos;
}

- (void)flushStore {
    [self.allProcessedPhotos removeAllObjects];
}

@end
