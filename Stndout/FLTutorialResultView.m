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

NSString *const kDefaultFemaleImage = @"Selected-Female-3";
NSString *const kDefaultMaleImage = @"Selected-Male-2";

@implementation FLTutorialResultView

- (IBAction)start:(id)sender {
    NSString *selectedPersona = [[FLSettings defaultSettings] selectedPersona];
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Education" properties:@{
                                             @"controller": NSStringFromClass([self class]),
                                             @"state": @"complete",
                                             @"persona": selectedPersona,
                                             @"matchPersona": _targetMatch
                                             }];

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

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"loaded"
                                               }];

    // Need a placeholder
    [_firstProfile sd_setImageWithURL:user.profileURL placeholderImage:[UIImage imageNamed:@"Persona"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        [user setImage:image];
    }];

    if (user.isMale){
        [_secondProfile setImage:[UIImage imageNamed:kDefaultFemaleImage]];
        _targetMatch = kDefaultFemaleImage;
    } else if (user.isFemale) {
        [_secondProfile setImage:[UIImage imageNamed:kDefaultMaleImage]];
        _targetMatch = kDefaultMaleImage;
    } else {
        NSLog(@"!WARN!: ResultView - no gender set - setting to female");
        _targetMatch = kDefaultFemaleImage;
    }

    // TODO: Start second button toggle
    [_secondProfile setAnimation:@"wobble"];
    [_secondProfile setCurve:@"linear"];
    [_secondProfile setDuration:1.0];
    [_secondProfile setDamping:1.0];
    [_secondProfile setVelocity:1];
    [_secondProfile performSelector:@selector(animate) withObject:nil afterDelay:1.0];

    [_heartIcon setAutohide:YES];
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

- (NSString *)randomFromArray:(NSArray *)imagesArray {
    NSUInteger randomIndex = arc4random() % [imagesArray count];
    return[imagesArray objectAtIndex:randomIndex];
}

- (void)toggleAlternate {
    if (_alternate) {
        _alternate = NO;
    } else {
        _alternate = YES;
    }
}

- (UIImage *)getAlternateImage {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    NSArray *maleImages = @[@"Selected-Male-1", @"Selected-Male-2", @"Selected-Male-3"];
    NSArray *femaleImages = @[@"Selected-Female-1", @"Selected-Female-2", @"Selected-Female-3"];

    [self toggleAlternate];

    if (user.isMale) {
        if (_alternate) {
            _targetMatch = [self randomFromArray:maleImages];
        } else {
            _targetMatch = [self randomFromArray:femaleImages];
        }
    } else if (user.isFemale) {
        if (_alternate) {
            _targetMatch = [self randomFromArray:femaleImages];
        } else {
            _targetMatch = [self randomFromArray:maleImages];
        }
    } else {
        NSLog(@"!WARN!: No gender set resultView");
    }

    return [UIImage imageNamed:_targetMatch];
}

- (void)flipMatch:(UITapGestureRecognizer *)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Gesture" properties:@{
                                            @"controller": NSStringFromClass([self class]),
                                            @"category": @"aesthetic",
                                            @"type": @"tap"
                                            }];

    void(^heartDisappear)(void)=^(void){
        [_heartIcon setAnimation:@"fadeOut"];
        [_heartIcon setCurve:@"linear"];
        [_heartIcon setDuration:0.5];
        [_heartIcon animateTo];
    };

    void(^heartPop)(void)=^(void){
        [_heartIcon setAnimation:@"pop"];
        [_heartIcon setCurve:@"linear"];
        [_heartIcon setDuration:1];
        [_heartIcon setRepeatCount:2];

        [_heartIcon animateToNext:heartDisappear];
    };

    void(^swapImage)(void)=^(void) {
        [_secondProfile setImage:[self getAlternateImage]];
    };

    void(^updateImage)(void)=^(void) {
        [_secondProfile setAnimation:@"wobble"];
        [_secondProfile setCurve:@"easInOutQuad"];
        [_secondProfile setDuration:0.5];
        [_secondProfile setScaleX:1];
        [_secondProfile setScaleY:1];
        [_secondProfile setDamping:1];
        [_secondProfile setVelocity:0.5];

        [_secondProfile animateToNext:swapImage];
    };

    void(^heartFadein)(void)=^(void) {
        [_heartIcon setAnimation:@"fadeIn"];
        [_heartIcon setCurve:@"spring"];
        [_heartIcon setDuration:0.5];
        [_heartIcon animateToNext:heartPop];
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
    [_secondProfile setRotate:2];
    [_secondProfile animateToNext:completionBlock];

    [_heartIcon setAnimation:@"fadeIn"];
    [_heartIcon setCurve:@"spring"];
    [_heartIcon setDuration:0.5];
    [_heartIcon setDelay:0.7];
    [_heartIcon animateToNext:heartFadein];
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
    float matchTitleFontSize = [FLViewHelpers titleCopyForScreenSize];

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
