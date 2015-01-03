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

@interface FLLoginViewController ()

@end

@implementation FLLoginViewController
{
    BOOL _viewDidAppear;
    BOOL _viewIsVisible;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

}

- (void)viewDidAppear:(BOOL)animated {
    self.loginView.readPermissions = @[@"public_profile", @"user_friends"];

    FLSettings *settings = [FLSettings defaultSettings];
    if (_viewDidAppear) {
        _viewIsVisible = YES;

        // reset
        settings.shouldSkipLogin = NO;
    } else {
        [FBSession openActiveSessionWithAllowLoginUI:NO];
        FBSession *session = [FBSession activeSession];

        if (settings.shouldSkipLogin || session.isOpen) {
            [self performSegueWithIdentifier:@"loggedIn" sender:nil];
        } else {
            _viewIsVisible = YES;
        }
        _viewDidAppear = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    [FLSettings defaultSettings].shouldSkipLogin = YES;
    _viewIsVisible = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - FBLoginViewDelegate

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error {
    FLErrorHandler(error);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user {

}

- (void)loginViewShowingLoggedInUser:(FBLoginView *)loginView {
    if (_viewIsVisible) {
        [self performSegueWithIdentifier:@"loggedIn" sender:loginView];
    }
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
