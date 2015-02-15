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


- (void)addAnnotatedPhoto:(FLPhoto *)photo {
    if(!self.allPhotos){
        self.allPhotos = [NSMutableArray new];
    }

    // If it already exists remove it
    for (FLPhoto* object in self.allPhotos) {
        if (object.id == photo.id) {
            [self.allPhotos removeObject:object];
        }
    }

    [self.allPhotos addObject:photo];
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

    for (FLPhoto* object in self.allPhotos) {
        if([stringId floatValue] == [object.id floatValue]) {
            [self.allPhotos removeObject:object];
        }
    }
}


@end
