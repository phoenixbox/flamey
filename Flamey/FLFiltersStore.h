//
//  FLFiltersStore.h
//  Flamey
//
//  Created by Shane Rogers on 2/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface FLFiltersStore : NSObject

+ (instancetype)sharedStore;

- (void)generateFiltersForImage:(UIImage *)image;

- (NSMutableArray *)allFilters;

@end
