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

- (void)addUniquePhoto:(FLPhoto *)photo {
    if(!self.allPhotos){
        self.allPhotos = [NSMutableArray new];
    }

    BOOL exists = NO;

    for (FLPhoto* object in self.allPhotos) {

        if (object.id == photo.id) {
            exists = YES;
        }
    }

    if (!exists) {
        [self.allPhotos addObject:photo];
    }
}

- (BOOL)isPhotoPresent:(NSString *)stringId {
    if(!self.allPhotos){
        self.allPhotos = [NSMutableArray new];
        return NO;
    }

    BOOL exists = NO;

    for (FLPhoto* object in self.allPhotos) {
        if([stringId floatValue] == [object.id floatValue]) {
            exists = YES;
        }
    }

    return exists;
}

- (void)removePhotoById:(NSString *)stringId {
    if(!self.allPhotos){
        self.allPhotos = [NSMutableArray new];
    }

    NSMutableArray *copy = [self.allPhotos mutableCopy];

    [copy enumerateObjectsUsingBlock:^(FLPhoto* object, NSUInteger index, BOOL *stop) {
        if([stringId floatValue] == [object.id floatValue]) {
            [self.allPhotos removeObject:object];
        }
    }];
}

@end