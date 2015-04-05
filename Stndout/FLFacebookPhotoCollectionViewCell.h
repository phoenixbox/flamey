//
//  FLNewFacebookPhotoCollectionViewCell.h
//  Flamey
//
//  Created by Shane Rogers on 1/30/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLFacebookPhotoCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageViewBackgroundImage;
@property (weak, nonatomic) IBOutlet UIImageView *selectedView;
@property (weak, nonatomic) IBOutlet UIImageView *editUnderlay;

- (void)setEditable:(BOOL)selected;
- (BOOL)inEditMode;

@end