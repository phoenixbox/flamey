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

// Components
#import "FLLoginSlide.h"

#import <FacebookSDK/FacebookSDK.h>
#import "FLErrorHandler.h"
#import "FLSettings.h"
#import "FLLoginView.h"

// TODO: Server Persistence Data Layer
#import "FLUser.h"

NSString *const kSegueLoggedIn = @"loggedIn";
NSString *const kLoginSlide = @"FLLoginSlide";


@interface FLLoginViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FLLoginViewController
{
    BOOL _viewDidAppear;
    BOOL _viewIsVisible;
    NSArray *_photos;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    // TODO: Remove these assignments when not in development
    FLSettings *settings = [FLSettings defaultSettings];
    settings.shouldSkipLogin = NO;
    [_titleLabel setText:@"Its hard to stand out"];
//    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//    [_hud setCenter:self.view.center];
//    _hud.mode = MBProgressHUDModeIndeterminate;
//    _hud.labelText = @"Loading";
}

#pragma mark SwipeView methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView {
    return 3;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kLoginSlide owner:nil options:nil];
    FLLoginSlide *loginSlide = (FLLoginSlide *)[nibContents lastObject];

    switch (index) {
        case 0:
            [loginSlide.tutorialImageView setImage:[UIImage imageNamed:@"LoginViewFirstScreen"]];
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
            [_titleLabel setText:@"Its hard to stand out"];
            break;
        case 1:
            [_titleLabel setText:@"We let you standout"];
            break;
        case 2:
            [(FLLoginSlide *)swipeView.currentItemView startAnimationLayers];
            [_titleLabel setText:@"So people can like you!"];
            break;
        default:
            NSLog(@"There is no title for that index");
            break;
    }
}

#pragma mark - Paging

- (IBAction)pageControlled:(id)sender {
    [_swipeView scrollToPage:[_pageControl currentPage] duration:0.3];
}


- (void)viewDidAppear:(BOOL)animated {
    _viewDidAppear = YES;

    FLSettings *settings = [FLSettings defaultSettings];
    NSArray *readPermissions = @[@"public_profile", @"user_friends", @"email", @"user_photos"];
//    _viewIsVisible = YES;
    // TODO: Remove the hardcoded segue

//    TODO Implement server side login persistence record
//    void(^completionBlock)(FLUser *user, NSError *err)=^(FLUser user*, NSError *err) {
//        if(!err){
//             Let the server tell us if the user has seen the tutorial
//             settings.seenTutorial = user.seenTutorial;
//            [self performSegueWithIdentifier:@"loggedIn" sender:nil];
//        } else {
//            NSLog(@"Problem with logging in on the server");
//        }
//    };

    if (_viewDidAppear && settings.needToLogin) {

        settings.shouldSkipLogin = NO;
    } else {
        [FBSession openActiveSessionWithReadPermissions:readPermissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                          if (!error && status == FBSessionStateOpen) {
                                              [self performSegueWithIdentifier:kSegueLoggedIn sender:nil];
                                              // TODO: Future Server persistence
//                                              [_hud show:YES];
//                                              [FLSessionStore loginUser:session withCompletionBlock:completionBlock];
                                          } else {
                                              _viewIsVisible = YES;
                                          }
                                      }];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [FLSettings defaultSettings].shouldSkipLogin = YES;
    _viewIsVisible = NO;
}

#pragma mark - FBLoginViewDelegate

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error {
    FLErrorHandler(error);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {
    // TODO:Retrieve required user details and persist to external server
    NSLog(@"%@", [NSString stringWithFormat:@"continue as %@", [user name]]);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:NSJSONWritingPrettyPrinted error:nil];
    NSString *result = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    FLUser *newUser = [[FLUser alloc] initWithString:result error:nil];

    NSString *graphPath = @"me/picture?type=large&redirect=false";

    [FBRequestConnection startWithGraphPath:graphPath parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            NSString *profileImage = [[result objectForKey:@"data"] objectForKey:@"url"];
            [newUser setProfileImage:profileImage];

            [[FLSettings defaultSettings] setUser:newUser];
        } else {
            NSLog(@"FBLogin user image error: %@", error);
        }
        [self performSegueWithIdentifier:kSegueLoggedIn sender:nil];
    }];
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