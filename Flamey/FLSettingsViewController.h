//
//  SecondViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FLSettingsViewController : UIViewController <FBLoginViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *logoutButton;
- (IBAction)logOut:(id)sender;


@end

