//
//  FLContactViewController.h
//  Flamey
//
//  Created by Shane Rogers on 2/20/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

#import "TTTAttributedLabel.h"

@interface FLContactViewController : UIViewController <
    TTTAttributedLabelDelegate,
    MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
@property (weak, nonatomic) IBOutlet UIImageView *stndoutLogo;
@property (weak, nonatomic) IBOutlet UILabel *createdByLabel;
@property (weak, nonatomic) IBOutlet UIImageView *replLogo;
@property (weak, nonatomic) IBOutlet UILabel *contactUsLabel;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *websiteLink;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *contactEmailLabel;
- (IBAction)back:(id)sender;

@end
