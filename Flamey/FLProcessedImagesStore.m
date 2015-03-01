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

- (void)removePhotoById:(NSString *)stringId {
    if(!_photos){
        _photos = [NSMutableArray new];
    }

    for (FLPhoto* object in _photos) {
        if([stringId floatValue] == [object.id floatValue]) {
            NSLog(@"Remove processed photo");
            [_photos removeObject:object];
        }
    }
}

- (void)addUniquePhoto:(FLPhoto *)photo {
    if(!_photos){
        _photos = [NSMutableArray new];
    }

    BOOL exists = NO;

    for (FLPhoto* object in _photos) {
        if (object.id == photo.id) {
            NSLog(@"exists");
            exists = YES;
        }
    }

    if (!exists) {
        [_photos addObject:photo];
    }
}

- (void)flushStore {
    [_photos removeAllObjects];
}

@end
