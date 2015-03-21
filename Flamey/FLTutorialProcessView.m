//
//  FLTutorialProcessView.m
//  Flamey
//
//  Created by Shane Rogers on 3/21/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialProcessView.h"

// Helpers
#import "FLViewHelpers.h"

@implementation FLTutorialProcessView

- (void)setContent {
    [self setFirstSectionContent];
    [self setSecondSectionContent];
    [self setThirdSectionContent];
}

- (void)setFirstSectionContent {
    // Set the copy
    NSString *copy = @"stndout lets you\n mark yourself in your\n facebook photos";
    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];;

    _firstCopy.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _firstCopy.textColor = [UIColor blackColor];
    _firstCopy.lineBreakMode = NSLineBreakByWordWrapping;
    _firstCopy.numberOfLines = 3;

    [_firstCopy setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"stndout" options:NSCaseInsensitiveSearch];

        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];

    // Set the image view
    [_firstImageView setImage:[UIImage imageNamed:@"Selected-Male-2"]];
    [_firstImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setSecondSectionContent {
}

- (void)setThirdSectionContent {
}

- (void)drawRect:(CGRect)rect {
    _contentView.layer.cornerRadius = 10;

    self.backgroundColor = [UIColor grayColor];
}

@end
