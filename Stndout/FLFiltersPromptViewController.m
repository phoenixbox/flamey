//
//  FLFiltersPromptViewController.m
//  Stndout
//
//  Created by Shane Rogers on 3/30/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFiltersPromptViewController.h"
#import "FLTutorialProcessView.h"
#import "FLTutorialSolutionView.h"

// Pods
#import "Mixpanel.h"

// DataLayer
#import "FLSettings.h"

// Helpers
#import "FLViewHelpers.h"

@interface FLFiltersPromptViewController ()

@end

@implementation FLFiltersPromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"loaded"
                                               }];

    [self styleModal];
    [self setReadyTitleCopy];
    [self setFirstLabelCopy];

    NSDictionary *imagesForView = [self imagesForSelectedPersona];
    NSString *imageName = [imagesForView objectForKey:kUploadImage];
    [_photoImageView setImage:[UIImage imageNamed:imageName]];
    [_photoImageView setContentMode:UIViewContentModeScaleAspectFill];

    [self styleLetMeKnowButton];
}

- (void)styleModal {
    _modalView.layer.cornerRadius = 10;
    _modalView.clipsToBounds = YES;
}

- (void)setReadyTitleCopy {
    _readyTitle.font = [UIFont fontWithName:@"Rochester" size:45.0];
}

- (void)setFirstLabelCopy {
    NSString *copy = @"We are still working on that!";
    float copySize = [FLViewHelpers bodyCopyForScreenSize];

    _firstLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:copySize];
    _firstLabel.textColor = [UIColor whiteColor];
    _firstLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _firstLabel.numberOfLines = 2;

    // If you're using a simple `NSString` for your text,
    // assign to the `text` property last so it can inherit other label properties.
    [_firstLabel setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"stndout" options:NSCaseInsensitiveSearch];

        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:copySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];
}

- (void)setSecondLabelCopy {
    NSString *copy = @"Soon you will be able to filter your facebook photos!";
    float copySize = [FLViewHelpers bodyCopyForScreenSize];

    _secondLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:copySize];
    _secondLabel.textColor = [UIColor whiteColor];
    _secondLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _secondLabel.numberOfLines = 3;

    // If you're using a simple `NSString` for your text,
    // assign to the `text` property last so it can inherit other label properties.
    [_secondLabel setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"privately!" options:NSCaseInsensitiveSearch];

        // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:copySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];
}

// TODO: Refactor out duplicated code
- (NSDictionary *)imagesForSelectedPersona {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;

    NSString *personaImage;
    NSString *uploadImage;

    NSString *selectedPersona = [[FLSettings defaultSettings] selectedPersona];

    if (user.isMale) {
        if ([selectedPersona isEqualToString:kMaleOneSelected]) {
            personaImage = kMaleImageOne;
            uploadImage = kMaleUploadOne;
        } else if ([selectedPersona isEqualToString:kMaleTwoSelected]) {
            personaImage = kMaleImageTwo;
            uploadImage = kMaleUploadTwo;
        } else if ([selectedPersona isEqualToString:kMaleThreeSelected]) {
            personaImage = kMaleImageThree;
            uploadImage = kMaleUploadThree;
        } else {
            NSLog(@"!WARN! no persona set in the settings");
            personaImage = kMaleImageOne;
            uploadImage = kMaleUploadOne;
        }
    } else if (user.isFemale) {
        if ([selectedPersona isEqualToString:kFemaleOneSelected]) {
            personaImage = kFemaleImageOne;
            uploadImage = kFemaleUploadOne;
        } else if ([selectedPersona isEqualToString:kFemaleTwoSelected]) {
            personaImage = kFemaleImageTwo;
            uploadImage = kFemaleUploadTwo;
        } else if ([selectedPersona isEqualToString:kFemaleThreeSelected]) {
            personaImage = kFemaleImageThree;
            uploadImage = kFemaleUploadThree;
        } else {
            NSLog(@"!WARN! no persona set in the settings");
            personaImage = kFemaleImageOne;
            uploadImage = kFemaleUploadOne;
        }
    } else {
        NSLog(@"!WARN! No gender is defined");
    }

    return @{ @"personaImage": personaImage, @"uploadImage": uploadImage };
}

- (void)styleLetMeKnowButton {
    [FLViewHelpers setBaseButtonStyle:_letMeKnowButton withColor:[UIColor whiteColor]];
    [_letMeKnowButton setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)understandAndMove {
    FLSettings *settings = [FLSettings defaultSettings];
    [settings setUnderstandAnnotation:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)close:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Education" properties:@{
                                              @"controller": NSStringFromClass([self class]),
                                              @"type": @"cancel"
                                              }];
    [self understandAndMove];

}

- (IBAction)letMeKnow:(id)sender {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Education" properties:@{
                                              @"controller": NSStringFromClass([self class]),
                                              @"type": @"accept"
                                              }];
    [self understandAndMove];

}

@end
