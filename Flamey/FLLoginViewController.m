//
//  LoginViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLLoginViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import "FLErrorHandler.h"
#import "FLSettings.h"
#import "FLLoginView.h"

@interface FLLoginViewController ()

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
    [self.flameyLogo setText:@"Flamey"];

    [self _configurePhotos];
}

#pragma mark - Class Methods

+ (NSArray *)demoPhotos
{
    return @[
             @{
                 @"title":@"Can't See You",
                 @"image": [UIImage imageNamed:@"test_image"]
                 },
             @{
                 @"title":@"Stand Out",
                 @"image": [UIImage imageNamed:@"ghost"]
                 },
             @{
                 @"title":@"Private",
                 @"image": [UIImage imageNamed:@"test_image"]
                 }
             ];
}

#pragma mark - Paging

- (IBAction)changePage:(id)sender
{
    UIScrollView *scrollView = self.scrollView;
    CGFloat x = floorf(self.pageControl.currentPage * scrollView.frame.size.width);
    [scrollView setContentOffset:CGPointMake(x, 0) animated:YES];
    [self _updateViewForCurrentPage];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.isDragging || scrollView.isDecelerating){
        UIPageControl *pageControl = self.pageControl;
        pageControl.currentPage = floorf(scrollView.contentOffset.x /
                                         (scrollView.contentSize.width / pageControl.numberOfPages));
        [self _updateViewForCurrentPage];
    }
}

#pragma mark - Helper Methods

- (void)_configurePhotos
{
    _photos = [[self class] demoPhotos];
    [self _updateViewForCurrentPage];
    [self _loginView].images = [_photos valueForKeyPath:@"image"];
}

- (NSDictionary *)_currentPhoto
{
    return _photos[self.pageControl.currentPage];
}

- (FLLoginView *)_loginView
{
    UIView *view = self.view;
    return ([view isKindOfClass:[FLLoginView class]] ? (FLLoginView *)view : nil);
}

- (void)_updateViewForCurrentPage
{
    NSDictionary *photo = [self _currentPhoto];
    // Trigger the setPhoto function in the loginView
    [self _loginView].photo = photo;
}

- (void)viewDidAppear:(BOOL)animated {
//    NSArray *readPermissions = @[@"public_profile", @"user_friends", @"email", @"user_photos"];

    FLSettings *settings = [FLSettings defaultSettings];
    // Local development Login bypass
    settings.shouldSkipLogin = NO;
    _viewIsVisible = YES;

//    [self performSegueWithIdentifier:@"loggedIn" sender:nil];
//    if (_viewDidAppear || settings.needToLogin) {
//
//        settings.shouldSkipLogin = NO;
//    } else {
//        [FBSession openActiveSessionWithReadPermissions:readPermissions
//                                           allowLoginUI:YES
//                                      completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
//                                          if (!error && status == FBSessionStateOpen) {
//                                              [self performSegueWithIdentifier:@"loggedIn" sender:nil];
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
    // Proceed into the app
    [self performSegueWithIdentifier:@"loggedIn" sender:nil];
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