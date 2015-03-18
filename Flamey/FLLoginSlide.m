//
//  FLLoginSlide.m
//  Flamey
//
//  Created by Shane Rogers on 3/16/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLLoginSlide.h"

@implementation FLLoginSlide

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)startAnimationLayers {
    float displacement = 15.0f;

    CGRect frameStart = _topAnimationImageView.frame;

    CGRect frame1 = CGRectMake(frameStart.origin.x,
                               frameStart.origin.y + displacement,
                               frameStart.size.width,
                               frameStart.size.height);

    CGRect frame2 = CGRectMake(frameStart.origin.x,
                               frame1.origin.y - displacement,
                               frameStart.size.width,
                               frameStart.size.height);


    [UIView animateKeyframesWithDuration:1.0
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat | UIViewAnimationOptionCurveEaseInOut animations:^{
        [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
            _topAnimationImageView.frame = frame1;
            _bottomAnimationImageView.frame = frame1;
        }];
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            _topAnimationImageView.frame = frame2;
            _bottomAnimationImageView.frame = frame2;
        }];
    } completion:nil];
}

- (void)buryMainImage {
    [self sendSubviewToBack:_tutorialImageView];
}

@end
