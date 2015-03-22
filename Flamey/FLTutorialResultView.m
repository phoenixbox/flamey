//
//  FLTutorialResultView.m
//  Flamey
//
//  Created by Shane Rogers on 3/19/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialResultView.h"
#import "FLViewHelpers.h"

// Pods
#import <SDWebImage/UIImageView+WebCache.h>

// Data Layer
#import "FLSettings.h"
#import "FLUser.h"

NSString *const kCompleteResult = @"completeResult";

@implementation FLTutorialResultView

- (IBAction)start:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:kCompleteResult
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

// RESTART: Switch content based on gender and sexual preference
// Use user profile image for the image
// Tap action on the counter image - Rotate for preference
- (void)setLabels {
    [self setTapGestureOnMatchProfile];

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

- (void)layoutSubviews {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    // Need a placeholder
    [_firstProfile sd_setImageWithURL:[NSURL URLWithString:user.profileImage] placeholderImage:nil];

    // TODO: Start second button toggle
    [_secondProfile setAnimation:@"wobble"];
    [_secondProfile setCurve:@"linear"];
    [_secondProfile setDuration:1.0];
    [_secondProfile setDamping:1.0];
    [_secondProfile setVelocity:1];

    [_secondProfile performSelector:@selector(animate) withObject:nil afterDelay:1.0];
}

- (void)setTapGestureOnMatchProfile {
    self.matchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(flipMatch:)];
    self.matchViewTap.numberOfTouchesRequired = 1;
    self.matchViewTap.numberOfTapsRequired = 1;

    [_secondProfile addGestureRecognizer:self.matchViewTap];
    // NOTE: Must set interaction true so that the gesture can be triggered
    // Dont have to have selector on the filter ImageView
    _secondProfile.userInteractionEnabled = YES;
}

- (void)flipMatch:(UITapGestureRecognizer *)sender {
    void(^updateImage)(void)=^(void) {
      [_secondProfile setImage:[UIImage imageNamed:@"Selected-Male-2"]];

        [_secondProfile setAnimation:@"wobble"];
        [_secondProfile setCurve:@"easInOutQuad"];
        [_secondProfile setDuration:0.7];
        [_secondProfile setScaleX:1];
        [_secondProfile setScaleY:1];
        [_secondProfile setDamping:1];
        [_secondProfile setVelocity:0.5];
        [_secondProfile animateTo];

        [_firstProfile setAnimation:@"wobble"];
        [_firstProfile setCurve:@"linear"];
        [_firstProfile setDuration:1.0];
        [_firstProfile setDamping:1.0];
        [_firstProfile setVelocity:1];
        [_firstProfile setDelay:0.7];
        [_firstProfile setX:0.1];
        [_firstProfile animate];
    };

    void(^completionBlock)(void)=^(void) {
        [_secondProfile setAnimation:@"pop"];
        [_secondProfile setCurve:@"easeIn"];
        [_secondProfile setDuration:0.7];
        [_secondProfile animateToNext:updateImage];
    };

    [_secondProfile setAnimation:@"flipX"];
    [_secondProfile setCurve:@"spring"];
    [_secondProfile setDuration:0.7];
    [_secondProfile setRotate:1];
    [_secondProfile animateToNext:completionBlock];
}

- (void)setupProfileImages {
    _contentView.layer.cornerRadius = 10;
    _contentView.clipsToBounds = YES;

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


@end
