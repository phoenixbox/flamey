//
//  FLTutorialHowView.m
//  Flamey
//
//  Created by Shane Rogers on 3/8/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialHowView.h"

NSString *const kContinueTutorial = @"continueTutorial";

@implementation FLTutorialHowView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)continue:(id)sender {
    // Update to trigger a slide to next step notification
    NSNotification *notification = [NSNotification notificationWithName:kContinueTutorial
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];

}

- (void)setLabelCopyAndStyles {
    float fontSize = 0;
    if ([UIScreen mainScreen].bounds.size.height == 480) {
        // iPhone 4
        fontSize = 13.0f;
        //        _secondSectionCopy.font.labelFontSize = 20.0f;
        //        label.font.fontWithSize(20)
    } else if ([UIScreen mainScreen].bounds.size.height == 568) {
        fontSize = 14.0f;
        // iPhone 5
    } else if ([UIScreen mainScreen].bounds.size.width == 375) {
        fontSize = 16.0f;
        // iPhone 6
    } else if ([UIScreen mainScreen].bounds.size.width == 414) {
        fontSize = 18.0f;
        // iPhone 6+
    } else if ([UIScreen mainScreen].bounds.size.width == 768) {
        // iPad
        fontSize = 18.0f;
    }

    [self setFirstSectionAttributedCopy:fontSize];
    [self setSecondSectionAttributedCopy:fontSize];
    [self setThirdSectionAttributedCopy:fontSize];
}

- (void)setFirstSectionAttributedCopy:(float)fontSize {
    NSString *copy = @"stndout makes it possible for you to mark yourself in your facebook photos";

    _firstSectionCopy.font = [UIFont fontWithName:@"AvenirNext-Regular" size:fontSize];
    _firstSectionCopy.textColor = [UIColor blackColor];
    _firstSectionCopy.lineBreakMode = NSLineBreakByWordWrapping;
    _firstSectionCopy.numberOfLines = 3;

    // If you're using a simple `NSString` for your text,
    // assign to the `text` property last so it can inherit other label properties.
    [_firstSectionCopy setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
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

- (void)setSecondSectionAttributedCopy:(float)fontSize {
    NSString *copy = @"We re-upload new enhanced photos privately to facebook so only you can see them. Guaranteed";
}

- (void)setThirdSectionAttributedCopy:(float)fontSize {
    NSString *copy = @"The dating apps that you use can then pick up these secret hidden photos.";
}

@end
