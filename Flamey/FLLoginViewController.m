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
//    _hud.mode = MBProgressHUDModeAnnularDeterminate;
//    _hud.labelText = @"Loading";

//    [self _configurePhotos];
}

#pragma mark SwipeView methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 3;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    NSLog(@"SWIPE INDEX*************** %lu", index);

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

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
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
//    NSArray *readPermissions = @[@"public_profile", @"user_friends", @"email", @"user_photos"];
    _viewIsVisible = YES;
    // TODO: Remove the hardcoded segue
//    [self performSegueWithIdentifier:kSegueLoggedIn sender:nil];
//    TODO Implement server side login persistence record
//    void(^completionBlock)(FLUser *user, NSError *err)=^(FLUser user*, NSError *err) {
//        if(!err){
//             Let the server tell us if the user has seen the tutorial
//             settings.seenTutorial = user.seenTutorial;
//            [self performSegueWithIdentifier:@"loggedIn" sender:nil];
//        } else {
//            NSLog(@"Problem with loggin in on the server");
//        }
//    };

//    [self performSegueWithIdentifier:@"loggedIn" sender:nil];
//    if (_viewDidAppear || settings.needToLogin) {
//
//        settings.shouldSkipLogin = NO;
//    } else {
//        [FBSession openActiveSessionWithReadPermissions:readPermissions
//                                           allowLoginUI:YES
//                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//                                          if (!error && status == FBSessionStateOpen) {
//                                              [_hud show:YES];
//                                              [FLSessionStore loginUser:session withCompletionBlock:completionBlock];
//                                          } else {
//                                              _viewIsVisible = YES;
//                                          }
//                                      }];
//        _viewDidAppear = YES;
//    }
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

    // Show the tutorial or show the selections screen
    // RESTART: Implement the 4 slider screens on the tutorial screen
    // Modal might have to be presented from the selections controller

    [self performSegueWithIdentifier:kSegueLoggedIn sender:nil];
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