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

- (IBAction)next:(id)sender {
}

- (void)setContent {
    [self setFirstSectionContent];
    [self setSecondSectionContent];
    [self setThirdSectionContent];
    [self setStartButtonStyleAndCopy];
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
    NSString *copy = @"We upload these photos\n privately to facebook where\n only you can see them\nGuaranteed";
    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];;

    _secondCopy.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _secondCopy.textColor = [UIColor blackColor];
    _secondCopy.lineBreakMode = NSLineBreakByWordWrapping;
    _secondCopy.numberOfLines = 5;

    [_secondCopy setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRangeOne = [[mutableAttributedString string] rangeOfString:@"privately" options:NSCaseInsensitiveSearch];
        NSRange boldRangeTwo = [[mutableAttributedString string] rangeOfString:@"Guaranteed" options:NSCaseInsensitiveSearch];

        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRangeOne];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRangeTwo];
;
            CFRelease(font);
        }

        return mutableAttributedString;
    }];

    // Set the image view
    [_secondImageView setImage:[UIImage imageNamed:@"MaleUploadFirst"]];
    [_secondImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setThirdSectionContent {
    NSString *copy = @"Your dating apps can then pick up these\n secret hidden photos";
    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];;

    _thirdCopy.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _thirdCopy.textColor = [UIColor blackColor];
    _thirdCopy.lineBreakMode = NSLineBreakByWordWrapping;
    _thirdCopy.numberOfLines = 3;

    [_thirdCopy setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRangeOne = [[mutableAttributedString string] rangeOfString:@"secret" options:NSCaseInsensitiveSearch];
        NSRange boldRangeTwo = [[mutableAttributedString string] rangeOfString:@"hidden" options:NSCaseInsensitiveSearch];

        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRangeOne];
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRangeTwo];

            CFRelease(font);
        }

        return mutableAttributedString;
    }];

    // Set the image view
    [_thirdImageView setImage:[UIImage imageNamed:@"DatingApps"]];
    [_thirdImageView setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)setStartButtonStyleAndCopy {
    [FLViewHelpers setBaseButtonStyle:_nextButton withColor:[UIColor blackColor]];
    float buttonCopySize = [FLViewHelpers buttonCopyForScreenSize];
    [_nextButton setTitle:@"Awesome!" forState:UIControlStateNormal];

    _nextButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:buttonCopySize];
}


- (void)drawRect:(CGRect)rect {
    _contentView.layer.cornerRadius = 10;

    self.backgroundColor = [UIColor grayColor];
}

@end
