//
//  CollectionViewHelpers.m
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "CollectionViewHelpers.h"

@implementation CollectionViewHelpers

+ (UICollectionViewFlowLayout *)buildLayoutWithWidth:(CGFloat)width {
    float const kPadding = 2.5;
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = kPadding;
    flowLayout.minimumInteritemSpacing = kPadding;
    CGFloat cellSize = (width - 5)/3;
    flowLayout.itemSize = CGSizeMake(cellSize,cellSize);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(kPadding, 0.0, kPadding, 0.0);

    return flowLayout;
}

@end
