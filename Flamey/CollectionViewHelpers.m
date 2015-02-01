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

+ (void)renderEmptyMessage:(NSString *)message forCollectionView:(UICollectionView *)view {
    UILabel *messageLabel = [[UILabel alloc] init];

    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:message attributes:@{NSFontAttributeName: [UIFont fontWithName:nil size:14.0]}];
    [messageLabel setAttributedText:attrText];

    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [messageLabel sizeToFit];

    messageLabel.center = view.center;
    view.backgroundView = messageLabel;
}

@end
