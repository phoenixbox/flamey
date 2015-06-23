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
#import "Mixpanel.h"

// Data Layer
#import "FLProcessedImagesStore.h"
#import "FLSettings.h"

// Helpers
#import "FLViewHelpers.h"

@interface FLFacebookUploadModalViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, assign) NSUInteger additionCounter;

@end

@implementation FLFacebookUploadModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_readyButton setBackgroundColor:[UIColor redColor]];
    FLSettings *settings = [FLSettings defaultSettings];

    [self styleModal];
    [self resetAdditionCounter];

    // Track Upload Screen Loaded
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                           @"controller": NSStringFromClass([self class]),
                                           @"state": @"loaded"
                                           }];

    if ([settings uploadPermission]) {
        [self uploadPhotos];
    } else {
        [self askPermissionTo:@"uploadPhotos"];
    }
}

- (void)resetAdditionCounter {
    _additionCounter = 0;
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

- (void)setBodyLabelCopy {
    NSString *copy = @"Working to help you stndout!";
    float bodyCopySize = [FLViewHelpers bodyCopyForScreenSize];

    _bodyLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:bodyCopySize];
    _bodyLabel.textColor = [UIColor whiteColor];
    _bodyLabel.lineBreakMode = NSLineBreakByWordWrapping;
    _bodyLabel.numberOfLines = 3;

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
    NSUInteger processedCount = [FLProcessedImagesStore sharedStore].photos.count;

    if (_additionCounter == processedCount) {
        [self resetAdditionCounter];
        [self setModalTitleFinished];
        [_readyButton setEnabled:YES];

        [FLViewHelpers setBaseButtonStyle:_readyButton withColor:[UIColor whiteColor]];
        float fontSize = [FLViewHelpers buttonCopyForScreenSize];
        _readyButton.titleLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:fontSize];
        [_readyButton setBackgroundColor:[UIColor clearColor]];

        [_bodyLabel setText:@"Now you stndout!\nOpen your dating apps and use your new photos!" afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
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
}

- (void)setFinishLogoAndTriggerProfileVIew {
    [_springLogo stopAnimating];

    [NSTimer scheduledTimerWithTimeInterval:0.5
                                     target:self
                                   selector:@selector(blurOutSpringLogo)
                                   userInfo:nil
                                    repeats:NO];
}

- (void)roundSpringLogo {
    _springLogo.layer.cornerRadius = _springLogo.bounds.size.width / 2;
    _springLogo.clipsToBounds = YES;
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
    [self roundSpringLogo];
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
    // Track Pre-Permission Request
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
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
                              [mixpanel track:@"FBPermissionRequest" properties:@{
                                                                         @"controller": NSStringFromClass([self class]),
                                                                         @"state": @"pre:default",
                                                                         @"result": @"success",
                                                                         }];
                              func(self, selector);
                          }];

    [alertView addButtonWithTitle:@"I'll ask later"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [mixpanel track:@"FBPermissionRequest" properties:@{
                                                                                     @"controller": NSStringFromClass([self class]),
                                                                                     @"state": @"pre:default",
                                                                                     @"result": @"failure",
                                                                                     }];
                              [settings setUploadPermission:NO];
                              [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                          }];
    
    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}

// TODO: Be aware of iOS version upload restrictions
- (void)uploadPhotos {
    FLSettings *settings = [FLSettings defaultSettings];
    FLUser *user = settings.user;
    // Track attempt to upload & how many photos being uploaded (ProcessedImagesCount)
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    // TODO: Ensure all images are being uploaded
    FLProcessedImagesStore *processedImageStore = [FLProcessedImagesStore sharedStore];
//    FLPhoto *processedPhoto = processedImageStore.photos.lastObject;
//    UIImage *img = processedPhoto.image;

    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setCenter:self.view.center];
    _hud.mode = MBProgressHUDModeAnnularDeterminate;
    _hud.labelText = @"Loading";

    // Low fidelity tracking data
    [self saveCountOfImages];

    for (FLPhoto* processedPhoto in processedImageStore.photos) {
        [self performPublishAction:^{
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
            | FBRequestConnectionErrorBehaviorAlertUser
            | FBRequestConnectionErrorBehaviorRetry;

            [_hud show:YES];

            [connection addRequest:[FBRequest requestForUploadPhoto:processedPhoto.image]

                 completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                     [_hud hide:YES];

                     if (!error) {
                         // NOTE: Tag the photo on completion
                         _additionCounter++;
                          NSLog(@"UPLOADED ANNOTATION #: %lu", (unsigned long)_additionCounter);
                         // RETRIEVE THE PHOTO ID
                         NSString *tagPath = [NSString stringWithFormat:@"/%@/tags", [result objectForKey:@"id"]];
                         NSString *userIDTag = [NSString stringWithFormat:@"[{'tag_uid': %@}]", user.id];
                         NSDictionary *params = @{ @"tags": userIDTag };
                         /* make the API call */
                         [FBRequestConnection startWithGraphPath:tagPath
                                                      parameters:params
                                                      HTTPMethod:@"POST"
                                               completionHandler:^(
                                                                   FBRequestConnection *connection,
                                                                   id result,
                                                                   NSError *error
                                                                   ) {
                                                   if(!error) {
                                                       NSLog(@"TAGGED ANNOTATION #: %lu", (unsigned long)_additionCounter);
                                                       [self setFinishedState];
                                                   } else {
                                                       // TODO: Implement Crashlytics
                                                   }
                                               }];
                     } else {
                         [mixpanel track:@"FBUpload" properties:@{
                                                                  @"controller": NSStringFromClass([self class]),
                                                                  @"state": @"initial",
                                                                  @"result": @"failure"
                                                                  }];
                         
                         [self showAlert:error withSelectorName:@"uploadPhotos"];
                     }
                 }];
            
            [connection start];
        }];
    }
}

- (void)saveCountOfImages {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    FLProcessedImagesStore *processedImageStore = [FLProcessedImagesStore sharedStore];
    NSNumber *count = [NSNumber numberWithInteger:[processedImageStore.photos count]];
    if (count == nil) {
        count = 0;
    }

    [mixpanel track:@"FBUpload" properties:@{
                                             @"controller": NSStringFromClass([self class]),
                                             @"state": @"initial",
                                             @"result": @"success",
                                             @"count": count
                                             }];
}

- (void)showAlert:(NSError *)error withSelectorName:(NSString *)selectorName {
    // Track Error Occurence
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

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
                              [mixpanel track:@"FBPermissionRequest" properties:@{
                                                                                  @"controller": NSStringFromClass([self class]),
                                                                                  @"state": @"pre:retry",
                                                                                  @"result": @"confirm"
                                                                                  }];
                              func(self, selector);
                          }];

    [alertView addButtonWithTitle:@"Try Later"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [mixpanel track:@"FBPermissionRequest" properties:@{
                                                                                     @"controller": NSStringFromClass([self class]),
                                                                                     @"state": @"pre:retry",
                                                                                     @"result": @"reject"
                                                                                     }];
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

#pragma mark - Facebook Private Permission Upload Request
- (void)performPublishAction:(void(^)(void))action {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    // Defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceOnlyMe
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    [mixpanel track:@"FBPermissionRequest" properties:@{
                                                                                                        @"controller": NSStringFromClass([self class]),
                                                                                                        @"state": @"default",
                                                                                                        @"result": @"success"
                                                                                                        }];
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    [mixpanel track:@"FBPermissionRequest" properties:@{
                                                                                                        @"controller": NSStringFromClass([self class]),
                                                                                                        @"state": @"default",
                                                                                                        @"result": @"failure"
                                                                                                        }];
                                                    [self facebookPermissionsDeniedAlert];
                                                }
                                            }];
    } else {
        action();
    }
}

- (void)facebookPermissionsDeniedAlert {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Permission Denied" andMessage:@"We can't help you stndout without permission to upload to Facebook"];

    [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

    [alertView addButtonWithTitle:@"Try Again"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [mixpanel track:@"FBPermissionRequest" properties:@{
                                                                                @"controller": NSStringFromClass([self class]),
                                                                                @"state": @"retry",
                                                                                @"result": @"confirm"
                                                                                }];
                              [self uploadPhotos];
                          }];

    [alertView addButtonWithTitle:@"Try Later"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [mixpanel track:@"FBPermissionRequest" properties:@{
                                                                                  @"controller": NSStringFromClass([self class]),
                                                                                  @"state": @"retry",
                                                                                  @"result": @"reject"
                                                                                  }];
                              [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                          }];

    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

    [alertView show];
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
