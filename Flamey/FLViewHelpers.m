//
//  FLViewHelpers.m
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLViewHelpers.h"

@implementation FLViewHelpers

+ (NSMutableAttributedString *)createIcon:(FAKFontAwesome *)icon withColor:(UIColor *)color {
    NSAttributedString *heartFont = [icon attributedString];
    NSMutableAttributedString *heartIcon = [heartFont mutableCopy];
    [heartIcon addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,heartIcon.length)];

    return heartIcon;
}

+ (NSAttributedString *)attributeText:(NSString *)text forFontSize:(CGFloat)size andFontFamily:(NSString *)fontFamily {
    return [[NSAttributedString alloc] initWithString:text attributes:@{NSFontAttributeName: [UIFont fontWithName:fontFamily size:size]}];
}

+ (void)formatLabel:(UILabel *)label withCopy:(NSString *)copy andFontFamily:(NSString *)fontFamily {
    if (!fontFamily) {
        fontFamily = @"AvenirNext-UltraLight";
    }

    [label setAttributedText:[self attributeText:copy forFontSize:10.0f andFontFamily:fontFamily]];
}

+ (void)sizeLabelToFit:(UILabel *)label numberOfLines:(CGFloat)lineNumber {
    // 0 is default
    [label setNumberOfLines:lineNumber];
    [label sizeToFit];
}

+ (void)scaleAndSetBackgroundImageNamed:(NSString *)imageName forView:(UIView *)targetView {
    UIImage *image = [UIImage imageNamed:imageName];
    UIGraphicsBeginImageContextWithOptions(targetView.frame.size, NO, image.scale);
    [image drawInRect:targetView.bounds];
    UIImage* redrawn = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [targetView setBackgroundColor:[UIColor colorWithPatternImage:redrawn]];
}

+ (void)scaleAndSetRemoteBackgroundImage:(NSString *)remoteURL forView:(UIView *)targetView {
    UIImage *image = [FLViewHelpers imageForURL:remoteURL];
    UIGraphicsBeginImageContextWithOptions(targetView.frame.size, NO, image.scale);
    [image drawInRect:targetView.bounds];
    UIImage *redrawn = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [targetView setBackgroundColor:[UIColor colorWithPatternImage:redrawn]];
}

+ (void)formatButton:(UIButton *)button forIcon:(NSMutableAttributedString *)icon withCopy:(NSString *)buttonCopy withColor:(UIColor *)color {
    NSMutableAttributedString *iconCopy =[[NSMutableAttributedString alloc] initWithString:buttonCopy attributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-Bold" size:10.0]}];
    if (icon) {
        [iconCopy appendAttributedString:icon];
    }
    [iconCopy addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor] range:NSMakeRange(0,iconCopy.length)];
    [button setAttributedTitle:iconCopy forState:UIControlStateNormal];
    [button.titleLabel setTextAlignment:NSTextAlignmentLeft];
    [button setBackgroundColor:color];
    button.layer.cornerRadius = 2.0f;
    button.layer.masksToBounds = YES;
}

+ (UIActivityIndicatorView *)setActivityIndicatorForNavItem:(UINavigationItem *)item {
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [item setTitleView:aiView];
    [aiView startAnimating];

    return aiView;
}

+ (UIImage *)imageForURL:(NSString *)imageURL {
    NSURL *url = [NSURL URLWithString:imageURL];
    NSData *data = [NSData dataWithContentsOfURL:url];

    return [UIImage imageWithData:data];
}

+ (void)rotate90Clockwise:(UIView *)object {
    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI_2);
    [object setTransform:rotate];
}

+ (NSAttributedString *)counterString:(NSString *)count withFontSize:(CGFloat)size {
    if (!count) {
        count = @"0";
    }

    return [FLViewHelpers attributeText:count forFontSize:size andFontFamily:nil];
}

+ (void)updateCount:(NSUInteger)number forLabel:(UILabel *)label {
    NSString *count = [NSString stringWithFormat:@"%tu", number];
    NSAttributedString *proposalCount = [FLViewHelpers attributeText:count forFontSize:12.0f andFontFamily:nil];
    [label setAttributedText:proposalCount];
}

+ (UILabel *)emptyTableMessage:(NSString *)message forView:(UIView *)view {
    UILabel *messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, view.bounds.size.width, view.bounds.size.height)];
    [FLViewHelpers formatLabel:messageLabel withCopy:message andFontFamily:nil];
    messageLabel.textColor = [UIColor blackColor];
    messageLabel.numberOfLines = 0;
    messageLabel.textAlignment = NSTextAlignmentCenter;
    [messageLabel sizeToFit];

    [FLViewHelpers rotate90Clockwise:messageLabel];

    return messageLabel;
}

+ (void)setButtonState:(BOOL)state forButton:(UIButton *)button withBackgroundColor:(UIColor *)color andCopy:(NSString *)copy {
    button.selected = state;
    [FLViewHelpers formatButton:button forIcon:nil withCopy:copy withColor:color];
}

+ (void)roundImageLayer:(CALayer *)layer withFrame:(CGRect)frame {
    layer.cornerRadius = frame.size.width/2;
    layer.masksToBounds = YES;
}


// REAFACTOR: Cant get case statement to work above

+ (NSMutableAttributedString *)upvoteCounterStringWithCopy:(NSString *)copy andFontSize:(CGFloat)fontSize {
    FAKFontAwesome *heart = [FAKFontAwesome thumbsUpIconWithSize:fontSize];
    NSAttributedString *heartFont = [heart attributedString];
    NSMutableAttributedString *heartIcon = [heartFont mutableCopy];

    NSAttributedString *favoriteCount = [FLViewHelpers counterString:copy withFontSize:fontSize];
    [heartIcon addAttribute:NSForegroundColorAttributeName value:[UIColor greenColor] range:NSMakeRange(0,heartIcon.length)];
    [heartIcon appendAttributedString:favoriteCount];
    [heartIcon insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];

    return heartIcon;
}

+ (NSMutableAttributedString *)heartCounterStringWithCopy:(NSString *)copy andFontSize:(CGFloat)fontSize {
    FAKFontAwesome *heart = [FAKFontAwesome heartIconWithSize:fontSize];
    NSAttributedString *heartFont = [heart attributedString];
    NSMutableAttributedString *heartIcon = [heartFont mutableCopy];

    NSAttributedString *favoriteCount = [FLViewHelpers counterString:copy withFontSize:fontSize];
    [heartIcon addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,heartIcon.length)];
    [heartIcon appendAttributedString:favoriteCount];
    [heartIcon insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];

    return heartIcon;
}

/// Invalid FAK Case statement
+ (void)iconCounter:(NSString *)iconType withCopy:(NSString *)copy andFontSize:(CGFloat)fontSize {

    void (^selectedCase)() = @{
                               @"upvote": ^{
                                   FAKFontAwesome *icon = [FAKFontAwesome thumbsUpIconWithSize:fontSize];
                                   return [self createIcon:icon withCopy:copy andFontSize:fontSize];
                               },
                               @"heart": ^{
                                   FAKFontAwesome *icon = [FAKFontAwesome heartIconWithSize:fontSize];
                                   return  [self createIcon:icon withCopy:copy andFontSize:fontSize];
                               }
                               }[iconType];

    if (selectedCase != nil) {
        selectedCase();
    }
}
\
+ (NSMutableAttributedString *)createIcon:(FAKFontAwesome *)icon withCopy:(NSString *)copy andFontSize:(CGFloat)fontSize {
    NSAttributedString *heartFont = [icon attributedString];
    NSMutableAttributedString *heartIcon = [heartFont mutableCopy];

    NSAttributedString *favoriteCount = [FLViewHelpers counterString:copy withFontSize:fontSize];
    [heartIcon addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(0,heartIcon.length)];
    [heartIcon appendAttributedString:favoriteCount];
    [heartIcon insertAttributedString:[[NSAttributedString alloc] initWithString:@" "] atIndex:1];
    
    return heartIcon;
}

+ (void)setBaseButtonStyle:(UIButton *)button withColor:(UIColor *)color {
    // TODO Update for state variety
    button.layer.cornerRadius = 4;
    button.layer.borderWidth = 2;
    button.layer.borderColor = color.CGColor;
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTintColor:color];
}

+ (float)fontForScreenSize {
    // TODO: Utilize for common appwide font size when necessary
//    if ([UIScreen mainScreen].bounds.size.height == 480) {
//        // iPhone 4 - 3.5
//    } else if ([UIScreen mainScreen].bounds.size.height == 568) {
//        // iPhone 5 - 4in
//        return 14.0f;
//    } else if ([UIScreen mainScreen].bounds.size.width == 375) {
//        // iPhone 6 - 4.7in
//        return 16.0f;
//    } else if ([UIScreen mainScreen].bounds.size.width == 414) {
//        // iPhone 6+ - 5.5in
//        return 18.0f;
//    } else if ([UIScreen mainScreen].bounds.size.width == 768) {
//        // iPad
//        return 18.0f;
//    }

    return 0;
}

@end

// Avenir Font Family
// **** Avenir Next
//AvenirNext-UltraLight
//AvenirNext-UltraLightItalic
//AvenirNext-Bold
//AvenirNext-BoldItalic
//AvenirNext-DemiBold
//AvenirNext-DemiBoldItalic
//AvenirNext-Medium
//AvenirNext-HeavyItalic
//AvenirNext-Heavy
//AvenirNext-Italic
//AvenirNext-Regular
//AvenirNext-MediumItalic