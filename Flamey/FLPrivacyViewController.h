//
//  FLPrivacyViewController.h
//  Flamey
//
//  Created by Shane Rogers on 3/28/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLPrivacyViewController : UIViewController
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *privacyTitle;
@property (weak, nonatomic) IBOutlet UITextView *privacyPolicyBody;

- (IBAction)back:(id)sender;
@end
