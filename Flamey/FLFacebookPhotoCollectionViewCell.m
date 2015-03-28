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
    [_editUnderlay setHidden:YES];
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

- (void)setEditable:(BOOL)selected {
    if (selected) {
        [_editUnderlay setHidden:NO];
    } else {
        [_editUnderlay setHidden:YES];
    }
}

- (BOOL)inEditMode {
    return _editUnderlay.hidden;
}


@end