//
//  FLLoginView.m
//  Flamey
//
//  Created by Shane Rogers on 3/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLLoginView.h"

@implementation FLLoginView
{
    NSArray *_imageViews;
}

#pragma mark - Properties

- (void)setImages:(NSArray *)images
{
    if (![_images isEqualToArray:images]) {
        _images = [images copy];

        [_imageViews makeObjectsPerformSelector:@selector(removeFromSuperview)];

        NSMutableArray *imageViews = [[NSMutableArray alloc] initWithCapacity:[images count]];
        UIScrollView *scrollView = self.scrollView;

        for (UIImage *image in images) {
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setContentMode:UIViewContentModeScaleAspectFit];

            [scrollView addSubview:imageView];
            [imageViews addObject:imageView];
        }

        _imageViews = imageViews;
        [self setNeedsLayout];
    }
}

- (void)setPhoto:(NSDictionary *)photo
{
    if (![_photo isEqual:photo]) {
        _photo = photo;
        _titleLabel.text = [photo objectForKey:@"title"];
    }
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];

    UIScrollView *scrollView = self.scrollView;
    CGSize scrollViewSize = scrollView.bounds.size;
    scrollView.contentSize = CGSizeMake(scrollViewSize.width * _imageViews.count,
                                        scrollViewSize.height);
    [_imageViews enumerateObjectsUsingBlock:^(UIView *imageView, NSUInteger idx, BOOL *stop) {
        CGSize imageViewSize = [imageView sizeThatFits:scrollViewSize];
        imageView.frame = CGRectMake(scrollViewSize.width * idx + floorf((scrollViewSize.width - imageViewSize.width) / 2),
                                     0.0,
                                     imageViewSize.height,
                                     imageViewSize.height);
    }];
}

@end
