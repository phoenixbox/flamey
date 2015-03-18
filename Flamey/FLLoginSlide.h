//
//  FLLoginSlide.h
//  Flamey
//
//  Created by Shane Rogers on 3/16/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CSAnimationView.h>

@interface FLLoginSlide : UIView
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UIImageView *topAnimationImageView;
@property (weak, nonatomic) IBOutlet UIImageView *bottomAnimationImageView;

@property (weak, nonatomic) IBOutlet CSAnimationView *bottomAnimationLayer;
@property (weak, nonatomic) IBOutlet CSAnimationView *topAnimationLayer;
- (void)addAnimationLayers;
- (void)startAnimationLayers;
- (void)buryMainImage;

@end
