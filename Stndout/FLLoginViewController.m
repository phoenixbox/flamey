//
//  LoginViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLLoginViewController.h"

// Libs
#import <MBProgressHUD/MBProgressHUD.h>
#import "Mixpanel.h"
#import <SIAlertView/SIAlertView.h>
#import <FacebookSDK/FacebookSDK.h>

// Components
#import "FLLoginSlide.h"
#import "FLErrorHandler.h"
#import "FLSettings.h"
#import "FLLoginView.h"

// TODO: Server Persistence Data Layer
#import "FLUser.h"

NSString *const kFirstSlideTitle = @"Its hard to stand out";
NSString *const kSecondSlideTitle = @"We make it easy!";
NSString *const kThirdSlideTitle = @"Stndout more - Get Matched More!";

NSString *const kSegueLoggedIn = @"loggedIn";
NSString *const kLoginSlide = @"FLLoginSlide";


@interface FLLoginViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FLLoginViewController
{
    NSArray *_photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"loaded"
                                               }];
    NSArray *readPermissions = @[@"public_profile", @"user_friends", @"email", @"user_photos"];
    [_loginView setReadPermissions:readPermissions];
    [_swipeView setBackgroundColor:[UIColor whiteColor]];

    // TODO: Remove these assignments when not in development
    [_titleLabel setText:kFirstSlideTitle];
}

#pragma mark SwipeView methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return 3;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kLoginSlide owner:nil options:nil];
    FLLoginSlide *loginSlide = (FLLoginSlide *)[nibContents lastObject];
    [loginSlide.tutorialImageView setContentMode:UIViewContentModeScaleAspectFit];
    [loginSlide.topAnimationImageView setContentMode:UIViewContentModeScaleAspectFit];
    [loginSlide.bottomAnimationImageView setContentMode:UIViewContentModeScaleAspectFit];

    switch (index) {
        case 0:
            [loginSlide.tutorialImageView setImage:[UIImage imageNamed:@"LoginViewFirstScreen"]];
            [loginSlide.tutorialImageView setContentMode:UIViewContentModeScaleAspectFit];
            break;
        case 1:
            [loginSlide.tutorialImageView setImage:[UIImage imageNamed:@"LoginViewSecondScreen"]];
            break;
        case 2:
            [loginSlide.topAnimationImageView setImage:[UIImage imageNamed:@"TopAnimationImageView"]];
            [loginSlide.bottomAnimationImageView setImage:[UIImage imageNamed:@"BottomAnimationImageView"]];
            [loginSlide.tutorialImageView setImage:[UIImage imageNamed:@"LoginViewThirdScreen"]];
            [loginSlide buryMainImage];
            break;
        default:
            NSLog(@"View Type Missing For Slide View");
            break;
    }

    view = loginSlide;
    
    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView {
    return self.swipeView.frame.size;
}

- (void)swipeViewCurrentItemIndexDidChange:(SwipeView *)swipeView {
    NSInteger index = swipeView.currentItemIndex;
    [_pageControl setCurrentPage:index];
    
    switch (index) {
        case 0:
            [self trackSlideViewing:@"First"];
            [_titleLabel setText:kFirstSlideTitle];
            break;
        case 1:
            [self trackSlideViewing:@"Second"];
            [_titleLabel setText:kSecondSlideTitle];
            break;
        case 2:
            [self trackSlideViewing:@"Third"];
            [(FLLoginSlide *)swipeView.currentItemView startAnimationLayers];
            [_titleLabel setText:kThirdSlideTitle];
            break;
        default:
            NSLog(@"There is no title for that index");
            break;
    }
}

- (void)trackSlideViewing:(NSString *)controller {
    NSString *slideType = [NSString stringWithFormat:@"loginSlide%@",controller];

    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": slideType,
                                               @"state": @"loaded"
                                               }];
}

#pragma mark - Paging

- (IBAction)pageControlled:(id)sender {
    [_swipeView scrollToPage:[_pageControl currentPage] duration:0.3];
}


- (void)viewDidAppear:(BOOL)animated {
}

- (void)viewWillAppear:(BOOL)animated {
    FLSettings *settings = [FLSettings defaultSettings];

    if (settings.user) {
        [self performSegueWithIdentifier:kSegueLoggedIn sender:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - FBLoginViewDelegate

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error {
    FLErrorHandler(error);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    // TODO:Retrieve required user details and persist to external server
    NSLog(@"%@", [NSString stringWithFormat:@"continue as %@", [user name]]);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error:nil];
    NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    FLUser *newUser = [[FLUser alloc] initWithString:result error:nil];

    // Setup Mixpanel Super Properties
    [self setTrackingSuperProperties:newUser];

    NSString *graphPath = @"me/picture?type=large&redirect=false";

    [FBRequestConnection startWithGraphPath:graphPath parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {

        if (!error) {
            // This event should have the superProperties attached
            [mixpanel track:@"Login" properties:@{
                                                    @"controller": NSStringFromClass([self class]),
                                                    @"state": @"default",
                                                    @"result": @"success",
                                                    }];
            NSString *profileImage = [[result objectForKey:@"data"] objectForKey:@"url"];
            [newUser setProfileImage:profileImage];

            [[FLSettings defaultSettings] setUser:newUser];
        } else {
            [mixpanel track:@"Login" properties:@{
                                                  @"controller": NSStringFromClass([self class]),
                                                  @"state": @"default",
                                                  @"result": @"failure",
                                                  @"error": error.localizedFailureReason
                                                  }];
        }
        
        [self performSegueWithIdentifier:kSegueLoggedIn sender:nil];
    }];
}

#pragma EventTracking
- (void)setTrackingSuperProperties:(FLUser *)user {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel registerSuperProperties:@{
                                        @"email": user.email,
                                        @"gender": user.gender,
                                        @"name": user.name,
                                        @"id": user.id,
                                        }];
}

- (void)loginViewShowingLoggedOutUser:(FBLoginView *)loginView {
// Get the logged out callback
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