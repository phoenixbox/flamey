//
//  FLTutorialResultView.m
//  Flamey
//
//  Created by Shane Rogers on 3/19/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialResultView.h"
#import "FLViewHelpers.h"
#import <tgmath.h>

@implementation FLTutorialResultView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self) {
        self.backgroundColor = [UIColor grayColor];
    }

    return self;
}

- (IBAction)start:(id)sender {
}

- (void)setLabels {
    [self setGetMatchedTitleCopy];
    [self setMatchTitleCopy];
    [self setExplanationCopy];
    [self setStartButtonStyleAndCopy];
}

- (void)setGetMatchedTitleCopy {
    NSDictionary *copySizes = [self copySizes];
    float matchTitleSize = [[copySizes objectForKey:@"matchTitleSize"] floatValue];
    _getMatchedTitle.font = [UIFont fontWithName:@"Rochester" size:matchTitleSize];
}

- (void)setMatchTitleCopy {
    NSString *copy = @"stndout more - get matched more";
    NSDictionary *copySizes = [self copySizes];

    float bodyCopySize = [[copySizes objectForKey:@"bodyCopySize"] floatValue];

    _matchTitle.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _matchTitle.textColor = [UIColor blackColor];
    _matchTitle.lineBreakMode = NSLineBreakByWordWrapping;
    _matchTitle.numberOfLines = 3;

    // If you're using a simple `NSString` for your text,
    // assign to the `text` property last so it can inherit other label properties.
    [_matchTitle setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"stndout" options:NSCaseInsensitiveSearch];

        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];
}

- (void)setExplanationCopy {
    NSString *copy = @"When people can see who you are\nYou are more likely to get matched\n\nSimple";
    NSDictionary *copySizes = [self copySizes];

    float bodyCopySize = [[copySizes objectForKey:@"bodyCopySize"] floatValue];

    _explanation.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _explanation.textColor = [UIColor blackColor];
    _explanation.lineBreakMode = NSLineBreakByWordWrapping;
    _explanation.numberOfLines = 5;

    // If you're using a simple `NSString` for your text,
    // assign to the `text` property last so it can inherit other label properties.
    [_explanation setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"Simple" options:NSCaseInsensitiveSearch];

        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];
}

- (void)setStartButtonStyleAndCopy {
    [FLViewHelpers setBaseButtonStyle:_startButton withColor:[UIColor blackColor]];
    NSDictionary *copySizes = [self copySizes];
    [_startButton setTitle:@"Let's Go!" forState:UIControlStateNormal];
    float buttonCopySize = [[copySizes objectForKey:@"buttonCopySize"] floatValue];

    _startButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:buttonCopySize];
}

- (void)drawRect:(CGRect)rect {
    [self setupProfileImages];
    
    self.backgroundColor = [UIColor grayColor];
}

- (void)setupProfileImages {
    _contentView.layer.cornerRadius = 10;
    _firstProfile.clipsToBounds = YES;

    _firstProfile.layer.cornerRadius = _firstProfile.bounds.size.width / 2;
    _firstProfile.clipsToBounds = YES;

    _secondProfile.layer.cornerRadius = _secondProfile.bounds.size.width / 2;
    _secondProfile.clipsToBounds = YES;
}

- (NSDictionary *)copySizes {
    float matchTitleFontSize;

    if ([UIScreen mainScreen].bounds.size.height == 480) {
        // iPhone 4 - 3.5
        matchTitleFontSize = 52.0f;
    } else if ([UIScreen mainScreen].bounds.size.height == 568) {
        // iPhone 5 - 4in
        matchTitleFontSize = 57.0f;
    } else if ([UIScreen mainScreen].bounds.size.width == 375) {
        // iPhone 6 - 4.7in
        matchTitleFontSize = 62.0f;
    } else if ([UIScreen mainScreen].bounds.size.width == 414) {
        // iPhone 6+ - 5.5in
        matchTitleFontSize = 74.0f;
    } else if ([UIScreen mainScreen].bounds.size.width == 768) {
        // iPad - WARN
        matchTitleFontSize = 80.0f;
    }

    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];
    // TODO: Design Button Sizes
    float buttonCopySize = [FLViewHelpers buttonCopyForScreenSize];

    NSDictionary *fontSizes = @{
             @"matchTitleSize": @(matchTitleFontSize),
             @"bodyCopySize": @(bodyCopySize),
             @"buttonCopySize": @(buttonCopySize)
             };

    return fontSizes;
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
