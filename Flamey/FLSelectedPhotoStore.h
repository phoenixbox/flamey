//
//  FLSelectedPhotoStore.h
//  Flamey
//
//  Created by Shane Rogers on 1/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLPhoto.h"

@interface FLSelectedPhotoStore : NSObject {
    NSMutableArray *photos;
}

@property (nonatomic, strong) NSMutableArray *allPhotos;

+ (FLSelectedPhotoStore *)sharedStore;

- (void)addUniquePhoto:(FLPhoto *)photo;

- (void)removePhotoById:(NSString *)stringId;

- (BOOL)isPhotoPresent:(NSString *)stringId;

- (NSMutableArray *)allPhotos;

@end
