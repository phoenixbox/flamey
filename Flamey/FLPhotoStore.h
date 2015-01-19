//
//  FLPhotoStore.h
//  Flamey
//
//  Created by Shane Rogers on 1/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLPhoto.h"

@interface FLPhotoStore : NSObject {
    NSMutableArray *photos;
}

@property (nonatomic, strong) NSMutableArray *allPhotos;

+ (FLPhotoStore *)sharedStore;

- (void)addUniquePhoto:(FLPhoto *)piece;

- (NSMutableArray *)allPhotos;

@end
