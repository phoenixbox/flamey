//
//  FLProcessedImagesStore.h
//  Flamey
//
//  Created by Shane Rogers on 2/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLPhoto.h"

@interface FLProcessedImagesStore : NSObject

@property (nonatomic, strong) NSMutableArray *photos;

+ (FLProcessedImagesStore *)sharedStore;

- (void)addUniquePhoto:(FLPhoto *)piece;

- (void)removePhotoById:(NSString *)stringId;

- (void)flushStore;

@end
