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

- (void)addAnimationLayers {
    _bottomAnimationLayer.duration = 0.5;
    _bottomAnimationLayer.delay    = 0;
    _bottomAnimationLayer.type     = CSAnimationTypeSlideDown;

    _topAnimationLayer.duration = 0.5;
    _topAnimationLayer.delay    = 0;
    _topAnimationLayer.type     = CSAnimationTypeSlideUp;
}

-(void)startAnimationLayers {
    [UIView animateKeyframesWithDuration:2.0 delay:0.0 options:UIViewKeyframeAnimationOptionAutoreverse | UIViewKeyframeAnimationOptionRepeat animations:^{
        [_topAnimationLayer startCanvasAnimation];
        [_bottomAnimationLayer startCanvasAnimation];
    } completion:nil];
}

- (void)buryMainImage {
    [self sendSubviewToBack:_tutorialImageView];
}

@end
