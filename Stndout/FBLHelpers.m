//
//  FBLHelpers.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "FBLHelpers.h"

void LoginUser(id target)
{
    NSLog(@"Require idea of a user store");
}

void PostNotification(NSString *notification)
{
    [[NSNotificationCenter defaultCenter] postNotificationName:notification object:nil];
}

NSString* TimeElapsed(NSTimeInterval seconds)
{
    NSString *elapsed;
    if (seconds < 60)
    {
        elapsed = @"Just now";
    }
    else if (seconds < 60 * 60)
    {
        int minutes = (int) (seconds / 60);
        elapsed = [NSString stringWithFormat:@"%d %@", minutes, (minutes > 1) ? @"mins" : @"min"];
    }
    else if (seconds < 24 * 60 * 60)
    {
        int hours = (int) (seconds / (60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", hours, (hours > 1) ? @"hours" : @"hour"];
    }
    else
    {
        int days = (int) (seconds / (24 * 60 * 60));
        elapsed = [NSString stringWithFormat:@"%d %@", days, (days > 1) ? @"days" : @"day"];
    }
    
    return elapsed;
}

UIImage* SquareImage(UIImage *image, CGFloat size) {
    UIImage *cropped;
    if (image.size.height > image.size.width)
    {
        CGFloat ypos = (image.size.height - image.size.width) / 2;
        cropped = CropImage(image, 0, ypos, image.size.width, image.size.width);
    }
    else
    {
        CGFloat xpos = (image.size.width - image.size.height) / 2;
        cropped = CropImage(image, xpos, 0, image.size.height, image.size.height);
    }

    UIImage *resized = ResizeImage(cropped, size, size);

    return resized;
}

UIImage* ResizeImage(UIImage *image, CGFloat width, CGFloat height) {
    CGSize size = CGSizeMake(width, height);
    CGRect rect = CGRectMake(0, 0, size.width, size.height);

    UIGraphicsBeginImageContextWithOptions(size, NO, 1.0);
    [image drawInRect:rect];
    UIImage *resized = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resized;
}

UIImage* CropImage(UIImage *image, CGFloat x, CGFloat y, CGFloat width, CGFloat height) {
    CGRect rect = CGRectMake(x, y, width, height);

    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    UIImage *cropped = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return cropped;
}
