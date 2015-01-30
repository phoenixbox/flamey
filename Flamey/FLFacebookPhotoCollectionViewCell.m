//
//  FLFacebookPhotoCollectionViewCell.m
//  Flamey
//
//  Created by Shane Rogers on 1/29/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookPhotoCollectionViewCell.h"

@implementation FLFacebookPhotoSelectedNumberView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.textAttributes = @{NSForegroundColorAttributeName:[UIColor whiteColor], NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Medium" size:12.0]};
    }

    return self;
}

- (void)setIndex:(NSUInteger)index {
    _index = MAX(1, index);
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGSize const size = self.bounds.size;
    CGFloat const lineWidth = 6.0;

    UIColor *strokeColor = self.normalColor;

    CGSize const rightCornerSize = CGSizeMake(23.0, 23.0);
    UIBezierPath* rectPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(size.width-rightCornerSize.width, 0, rightCornerSize.width, rightCornerSize.height) cornerRadius:3.0];
    [strokeColor setFill];
    [rectPath fill];

    NSString *text = [NSString stringWithFormat:@"%lu", (unsigned long)self.index];
    CGSize textSize = [text boundingRectWithSize:CGSizeMake(1000, 100) options:NSStringDrawingUsesLineFragmentOrigin attributes:self.textAttributes context:nil].size;
    [text drawInRect:CGRectMake(size.width-textSize.width-lineWidth, lineWidth*0.5, textSize.width, textSize.height) withAttributes:self.textAttributes];


    UIBezierPath *path = [UIBezierPath bezierPathWithRect:self.bounds];
    path.lineWidth = lineWidth;
    [strokeColor setStroke];
    [path stroke];
}

@end



@interface FLFacebookPhotoCollectionViewCell ()

@end

@implementation FLFacebookPhotoCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];

    if(self){
        self.imageView = [[UIImageView alloc] initWithFrame:frame];
        self.imageView.tag = 100;
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;

        [self.contentView addSubview:self.imageView];

        self.numberView = [[FLFacebookPhotoSelectedNumberView alloc] initWithFrame:self.bounds];
    }
    return self;
}

- (void)setSelected:(BOOL)selected {
    if (selected) {
        [self.contentView addSubview:self.numberView];
    } else {
        [self.numberView removeFromSuperview];
    }

    [super setSelected:selected];
}

- (void)prepareForReuse {
    self.numberView.index = 5;

    [super prepareForReuse];
}

- (void)bounce {
    self.transform = CGAffineTransformMakeScale(0.97, 0.97);
    [UIView animateWithDuration:0.8
                          delay:0.0
         usingSpringWithDamping:0.3
          initialSpringVelocity:1
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                     } completion:nil];
}

@end
