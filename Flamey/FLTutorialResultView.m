//
//  FLTutorialResultView.m
//  Flamey
//
//  Created by Shane Rogers on 3/19/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialResultView.h"
#import "FLViewHelpers.h"

@implementation FLTutorialResultView

- (void)setLabels {
    float fontSize = [FLViewHelpers fontForScreenSize];

    [self setMatchTitleCopy:fontSize];
    [self setGetMatchedTitleStyle];
    [self setupProfiles];
}

- (void)setGetMatchedTitleStyle {
    _getMatchedTitle.font = [UIFont fontWithName:@"Rochester" size:65.0f];
}

- (void)setupProfiles {
    // UI constraints should have these profiles the same size
    float firstProfileWidth = _firstProfile.image.size.width;
    _firstProfile.layer.cornerRadius = firstProfileWidth/2;

    float secondProfileWidth = _secondProfile.image.size.width;
    _secondProfile.layer.cornerRadius = secondProfileWidth/2;
}


- (void)setMatchTitleCopy:(float)fontSize {
    NSString *copy = @"stndout more - get matched more";

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
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
