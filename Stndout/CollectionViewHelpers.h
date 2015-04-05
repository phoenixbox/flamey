//
//  CollectionViewHelpers.h
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CollectionViewHelpers : NSObject

+ (UICollectionViewFlowLayout *)buildLayoutWithWidth:(CGFloat)width;

+ (void)renderEmptyMessage:(NSString *)message forCollectionView:(UICollectionView *)view;

@end
