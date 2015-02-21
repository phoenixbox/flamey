//
//  FLAnnotationStore.h
//  Flamey
//
//  Created by Shane Rogers on 2/15/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLPhoto.h"

@interface FLAnnotationStore : NSObject {
    NSMutableArray *photos;
}

@property (nonatomic, strong) NSMutableArray *allPhotos;

+ (FLAnnotationStore *)sharedStore;

- (void)addUniquePhoto:(FLPhoto *)photo;

- (void)addAnnotatedPhoto:(FLPhoto *)piece;

- (void)removePhotoById:(NSString *)stringId;

- (BOOL)isPhotoPresent:(NSString *)stringId;

- (NSMutableArray *)allPhotos;

- (void)flushStore;

@end