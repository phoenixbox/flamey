//
//  LoginViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <FacebookSDK/FacebookSDK.h>

@interface FLLoginViewController : UIViewController <FBLoginViewDelegate>
@property (strong, nonatomic) IBOutlet UILabel *flameyLogo;
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;

@end
