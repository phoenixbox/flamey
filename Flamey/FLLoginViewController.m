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

    [self.flameyLogo setText:@"Flamey"];
}

- (void)viewDidAppear:(BOOL)animated {
//    NSArray *readPermissions = @[@"public_profile", @"user_friends", @"email", @"user_photos"];

    FLSettings *settings = [FLSettings defaultSettings];
    // Local development Login bypass
    settings.shouldSkipLogin = NO;
    _viewIsVisible = YES;
    [self performSegueWithIdentifier:@"loggedIn" sender:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - FBLoginViewDelegate

- (void)loginView:(FBLoginView *)loginView
      handleError:(NSError *)error {
    FLErrorHandler(error);
}

- (void)loginViewFetchedUserInfo:(FBLoginView *)loginView user:(id<FBGraphUser>)user
{
    // TODO:Retrieve required user details and persist to external server
    NSLog(@"%@", [NSString stringWithFormat:@"continue as %@", [user name]]);
    // Proceed into the app
    [self performSegueWithIdentifier:@"loggedIn" sender:nil];
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
