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

- (void)setLabels {
    [self setMatchTitleCopy];
}

- (void)setMatchTitleCopy {
    NSString *copy = @"stndout more - get matched more";
    NSDictionary *copySizes = [self copySizes];
    float fontSize = [[copySizes objectForKey:@"matchTitleSize"] floatValue];

    _matchTitle.font = [UIFont fontWithName:@"AvenirNext-Regular" size:fontSize];
    _matchTitle.textColor = [UIColor blackColor];
    _matchTitle.lineBreakMode = NSLineBreakByWordWrapping;
    _matchTitle.numberOfLines = 3;

    // If you're using a simple `NSString` for your text,
    // assign to the `text` property last so it can inherit other label properties.
    [_matchTitle setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"stndout" options:NSCaseInsensitiveSearch];

        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:fontSize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];
}

- (void)drawRect:(CGRect)rect {
    [self setupProfileImages];
    
    self.backgroundColor = [UIColor grayColor];
}

- (void)setupProfileImages {
    _firstProfile.layer.cornerRadius = _firstProfile.bounds.size.width / 2;
    _firstProfile.clipsToBounds = YES;

    _secondProfile.layer.cornerRadius = _secondProfile.bounds.size.width / 2;
    _secondProfile.clipsToBounds = YES;
}

- (NSDictionary *)copySizes {
    float matchTitleFontSize;
    float bodycopySize;
    float buttonCopySize;

    if ([UIScreen mainScreen].bounds.size.height == 480) {
        // iPhone 4 - 3.5
        matchTitleFontSize = 48.0f;
    } else if ([UIScreen mainScreen].bounds.size.height == 568) {
        // iPhone 5 - 4in
        matchTitleFontSize = 50.0f;
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

    NSDictionary *fontSizes = @{
             @"matchTitleSize": @(matchTitleFontSize),
             @"bodyCopySize": @(bodycopySize),
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
