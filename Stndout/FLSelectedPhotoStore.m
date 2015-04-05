//
//  FLSelectedPhotoStore.m
//  Flamey
//
//  Created by Shane Rogers on 1/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLSelectedPhotoStore.h"

@implementation FLSelectedPhotoStore

+ (FLSelectedPhotoStore *)sharedStore {
    static FLSelectedPhotoStore *photoStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        photoStore = [[FLSelectedPhotoStore alloc] init];
    });
    return photoStore;
}

- (BOOL)photosPresent {
    return [_photos count] > 0;
}

- (void)addUniquePhoto:(FLPhoto *)photo {
    if(!_photos){
        _photos = [NSMutableArray new];
    }

    BOOL exists = NO;

    for (FLPhoto* object in _photos) {

        if (object.id == photo.id) {
            exists = YES;
        }
        NSLog(@"ID ********* %@", photo.id);
    }

    if (!exists) {
        [_photos addObject:photo];
    }

    NSLog(@"********** PHOTOS COUNT: %lu", (unsigned long)[_photos count]);
}

- (BOOL)isPhotoPresent:(NSString *)stringId {
    if(!_photos){
        _photos = [NSMutableArray new];
        return NO;
    }

    BOOL exists = NO;

    for (FLPhoto* object in _photos) {
        if([stringId floatValue] == [object.id floatValue]) {
            exists = YES;
        }
    }

    return exists;
}

- (void)removePhotoById:(NSString *)stringId {
    if(!_photos){
        _photos = [NSMutableArray new];
    }

    NSMutableArray *copy = [_photos mutableCopy];

    [copy enumerateObjectsUsingBlock:^(FLPhoto* object, NSUInteger index, BOOL *stop) {
        if([stringId floatValue] == [object.id floatValue]) {
            [_photos removeObject:object];
        }
    }];

    NSLog(@"********** PHOTOS COUNT: %lu", (unsigned long)[_photos count]);
}

@end