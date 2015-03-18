//
//  FLLoginSlide.h
//  Flamey
//
//  Created by Shane Rogers on 3/16/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLLoginSlide : UIView
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topAnimationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomAnimationImageView;

- (void)startAnimationLayers;
- (void)buryMainImage;

@end
