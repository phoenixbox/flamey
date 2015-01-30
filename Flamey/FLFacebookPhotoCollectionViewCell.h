//
//  FLFacebookPhotoCollectionViewCell.h
//  Flamey
//
//  Created by Shane Rogers on 1/29/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLFacebookPhotoSelectedNumberView : UIView

@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, strong) UIColor *normalColor;
@property (nonatomic, strong) NSDictionary *textAttributes;

@end

@interface FLFacebookPhotoCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) FLFacebookPhotoSelectedNumberView *numberView;

- (void)bounce;

@end
