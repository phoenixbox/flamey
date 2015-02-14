//
//  FLProcessedImagesStore.h
//  Flamey
//
//  Created by Shane Rogers on 2/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLPhoto.h"

@interface FLProcessedImagesStore : NSObject {
    NSMutableArray *processedPhotos;
}

@property (nonatomic, strong) NSMutableArray *allProcessedPhotos;

+ (FLProcessedImagesStore *)sharedStore;

- (void)addUniquePhoto:(FLPhoto *)piece;

- (NSMutableArray *)allPhotos;

@end
