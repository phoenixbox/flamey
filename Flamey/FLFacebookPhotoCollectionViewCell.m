//
//  FLNewFacebookPhotoCollectionViewCell.m
//  Flamey
//
//  Created by Shane Rogers on 1/30/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookPhotoCollectionViewCell.h"

@implementation FLFacebookPhotoCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    [_selectedView setHidden:YES];
}

- (void)setSelected:(BOOL)selected
{
    if (selected) {
        [_selectedView setHidden:NO];
    } else {
        [_selectedView setHidden:YES];
    }

    [super setSelected:selected];
}


@end