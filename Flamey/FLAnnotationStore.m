//
//  FLAnnotationStore.m
//  Flamey
//
//  Created by Shane Rogers on 2/15/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLAnnotationStore.h"

@implementation FLAnnotationStore

+ (FLAnnotationStore *)sharedStore {
    static FLAnnotationStore *annotatedStore = nil;

    static dispatch_once_t oncePredicate;

    dispatch_once(&oncePredicate, ^{
        annotatedStore = [[FLAnnotationStore alloc] init];
    });

    return annotatedStore;
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
    }

    if (!exists) {
        [_photos addObject:photo];
    }
}


- (void)addAnnotatedPhoto:(FLPhoto *)photo {
    if(!_photos){
        _photos = [NSMutableArray new];
    }

    // If it already exists remove it
    for (FLPhoto* object in _photos) {
        if (object.id == photo.id) {
            [_photos removeObject:object];
        }
    }

    [_photos addObject:photo];
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

    for (FLPhoto* object in _photos) {
        if([stringId floatValue] == [object.id floatValue]) {
            NSLog(@"Remove photo");
            [_photos removeObject:object];
        }
    }
}

- (void)flushStore {
    [_photos removeAllObjects];
}

@end
