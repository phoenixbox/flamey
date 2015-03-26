//
//  FBSaveModalViewController.m
//  Flamey
//
//  Created by Shane Rogers on 2/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookUploadModalViewController.h"

// Libs
#import <MBProgressHUD/MBProgressHUD.h>
#import <SIAlertView.h>
#import <SDWebImage/UIImageView+WebCache.h>

// Data Layer
#import "FLProcessedImagesStore.h"
#import "FLSettings.h"

// Helpers
#import "FLViewHelpers.h"

@interface FLFacebookUploadModalViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FLFacebookUploadModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_readyButton setBackgroundColor:[UIColor redColor]];
    FLSettings *settings = [FLSettings defaultSettings];

    [self styleModal];

    if ([settings uploadPermission]) {
        [self uploadPhotos];
    } else {
        [self askPermissionTo:@"uploadPhotos"];
    }
}

- (void)viewDidLayoutSubviews {
    [NSTimer scheduledTimerWithTimeInterval:1.0
                                     target:self selector:@selector(animateSpringLogo)
                                   userInfo:nil
                                    repeats:YES];
}
- (void)styleModal {
    [self roundModal];
    [self setModalTitleCopy];
    [self setBodyLabelCopy];
    [self setSpringLogo];
    [self styleReadyButton];
}

- (void)roundModal {
    _modalView.layer.cornerRadius = 10;
    _modalView.clipsToBounds = YES;
}

- (void)setModalTitleCopy {
    _modalTitle.font = [UIFont fontWithName:@"Rochester" size:[FLViewHelpers titleCopyForScreenSize]];
}

- (void)setModalTitleFinished {
    CATransition *transitionAnimation = [CATransition animation];
    [transitionAnimation setType:kCATransitionFade];
    [transitionAnimation setDuration:0.3f];
    [transitionAnimation setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [transitionAnimation setFillMode:kCAFillModeBoth];
    [_modalTitle.layer addAnimation:transitionAnimation forKey:@"fadeAnimation"];

    [_modalTitle setText:@"Finished!"];
}

- (void)setSpringLogo {
    [_springLogo setImage:[UIImage imageNamed:@"BigMarker"]];
    [_springLogo setContentMode:UIViewContentModeScaleAspectFit];
}

- (void)animateSpringLogo {
    [_springLogo setAnimation:@"pop"];
    [_springLogo setCurve:@"linear"];
    [_springLogo setForce:1];
    [_springLogo setDuration:0.5];
}

// RESTART
// Mock an upload finished timer - then animate in another profile image view
// Drop down some hearts and pulsate them

- (void)setBodyLabelCopy {
    NSString *copy = @"Working to help you stndout!";
    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];

    _bodyLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _bodyLabel.textColor = [UIColor whiteColor];
    _bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _bodyLabel.numberOfLines = 2;

    [_bodyLabel setText:copy afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"stndout" options:NSCaseInsensitiveSearch];

        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:bodyCopySize];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];
}

- (void)styleReadyButton {
    [FLViewHelpers setBaseButtonStyle:_readyButton withColor:[UIColor grayColor]];
    [_readyButton setBackgroundColor:[UIColor clearColor]];

    float fontSize = [FLViewHelpers buttonCopyForScreenSize];
    _readyButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:fontSize];
    [_readyButton setTitle:@"Not Finished Yet" forState:UIControlStateDisabled];
    [_readyButton setTitleColor:[UIColor grayColor] forState:UIControlStateDisabled];

    [_readyButton setTitle:@"Continue" forState:UIControlStateNormal];
    [_readyButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    [_readyButton setEnabled:NO];
}

- (void)setFinishedState {
    [self setModalTitleFinished];
    [_readyButton setEnabled:YES];

    [FLViewHelpers setBaseButtonStyle:_readyButton withColor:[UIColor whiteColor]];
    float fontSize = [FLViewHelpers buttonCopyForScreenSize];
    _readyButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:fontSize];
    [_readyButton setBackgroundColor:[UIColor clearColor]];

    [_bodyLabel setText:@"Now you stndout!" afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"stndout" options:NSCaseInsensitiveSearch];

        UIFont *boldSystemFont = [UIFont fontWithName:@"AvenirNext-Bold" size:[FLViewHelpers buttonCopyForScreenSize]];
        CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
        if (font) {
            [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
            CFRelease(font);
        }

        return mutableAttributedString;
    }];

    [self setFinishLogoAndTriggerProfileVIew];
}

- (void)setFinishLogoAndTriggerProfileVIew {
    [_springLogo stopAnimating];

    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(blurOutSpringLogo)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)blurOutSpringLogo {
    FLSettings *sharedSettings = [FLSettings defaultSettings];
    FLUser *user = sharedSettings.user;

    void(^fadeInProfileImage)(void)=^(void) {

        if (user.image) {
            [_springLogo setImage:user.image];
            [self setFinishedLogo];
        } else {
            UIImage *persona =[UIImage imageNamed:@"Persona"];

            [_springLogo sd_setImageWithURL:user.profileURL
                           placeholderImage:persona
                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                      [self setFinishedLogo];
                                  }
             ];
        }
    };

    [_springLogo setAnimation:@"zoomOut"];
    [_springLogo setCurve:@"easeInQuad"];
    [_springLogo setForce:1];
    [_springLogo setDuration:1.0];
    [_springLogo animateToNext:fadeInProfileImage];
}

-(void)setFinishedLogo {
    [_springLogo setAnimation:@"zoomIn"];
    [_springLogo setCurve:@"easeInQuad"];
    [_springLogo setForce:1];
    [_springLogo setDuration:1.0];
    [_springLogo animate];

    [self triggerHearts];
}

- (void)triggerHearts {
    NSArray *animationFunctions = @[@"animateHeartOne",
                             @"animateHeartTwo"];

    for (int i=0; i < [animationFunctions count]; i++) {
        NSString *selectorName = [animationFunctions objectAtIndex:i];
        SEL selector = NSSelectorFromString(selectorName);

        [NSTimer scheduledTimerWithTimeInterval:1.5
                                         target:self
                                       selector:selector
                                       userInfo:nil
                                        repeats:YES];
    }

}

-(void)animateHeartOne {
// TODO: Figure out better chaining of animations
//    void(^fadeBlock)(void)=^(void) {
//        [_heartOne setAnimation:@"zoomOut"];
//        [_heartOne setCurve:@"spring"];
//        [_heartOne setDuration:0.5];
//        [_heartOne animate];
//    };

    [self setHeartInImageView:_heartOne];

    [_heartOne setAnimation:@"shake"];
    [_heartOne setCurve:@"easeOutQuad"];
    [_heartOne setDuration:2];
    [_heartOne setDamping:0.7];
    [_heartOne setY:128.3];
    [_heartOne animate];
}

-(void)animateHeartTwo {
    [self setHeartInImageView:_heartTwo];

    [_heartTwo setAnimation:@"shake"];
    [_heartTwo setCurve:@"linear"];
    [_heartTwo setDuration:1.5];
    [_heartTwo setDamping:0.7];
    [_heartTwo setVelocity:1.0];
    [_heartTwo setY:100];
    [_heartTwo animate];
}

- (void)setHeartInImageView:(SpringImageView *)imageView {
    [imageView setImage:[UIImage imageNamed:@"heartIcon"]];
    imageView.layer.cornerRadius = _heartOne.bounds.size.width / 2;
    imageView.clipsToBounds = YES;
}

// TODO: Remove the animations when the view is destoryed || investigate garbage collection more

- (void)askPermissionTo:(NSString *)selectorName {
    FLSettings *settings = [FLSettings defaultSettings];

    SEL selector = NSSelectorFromString(selectorName);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Ready To Go!" andMessage:@"Facebook will now ask you for permission to privately upload the photos you have just marked"];

    [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

    [alertView addButtonWithTitle:@"Lets Go!"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [settings setUploadPermission:YES];
                              func(self, selector);
                          }];

    [alertView addButtonWithTitle:@"I'll ask later"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              [settings setUploadPermission:NO];
                              [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}

// TODO: Be aware of iOS version upload restrictions
- (void)uploadPhotos {
     [self setFinishedState];
//    FLProcessedImagesStore *processedImageStore = [FLProcessedImagesStore sharedStore];
//    FLPhoto *processedPhoto = processedImageStore.photos.lastObject;
//    UIImage *img = processedPhoto.image;
//
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_hud setCenter:self.view.center];
//    _hud.mode = MBProgressHUDModeAnnularDeterminate;
//    _hud.labelText = @"Loading";
//
//    [self performPublishAction:^{
//        FBRequestConnection *connection = [[FBRequestConnection alloc] init];
//        connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
//        | FBRequestConnectionErrorBehaviorAlertUser
//        | FBRequestConnectionErrorBehaviorRetry;
//
//        [_hud show:YES];
//
//        [connection addRequest:[FBRequest requestForUploadPhoto:img]
//
//         completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
//             [_hud hide:YES];
//             if (!error) {
//                 [self setFinishedState];
//               } else {
//                   [self showAlert:error withSelectorName:@"uploadPhotos"];
//               }
//         }];
//
//        [connection start];
//    }];
}

- (void)showAlert:(NSError *)error withSelectorName:(NSString *)selectorName {
    SEL selector = NSSelectorFromString(selectorName);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Uh Oh Facebook!" andMessage:@"Something went wrong when we tried to upload to Facebook"];

    [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

    [alertView addButtonWithTitle:@"Try Again"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              func(self, selector);
                          }];

    [alertView addButtonWithTitle:@"Try Later"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                          }];

    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

    [alertView show];
}

- (void)requestConnection:(FBRequestConnection *)connection
          didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    float progress = totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"Progress Total: %f", progress);
    _hud.progress = progress;
}


- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceOnlyMe
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }
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

@end
