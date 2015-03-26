//
//  FBSaveModalViewController.h
//  Flamey
//
//  Created by Shane Rogers on 2/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "TTTAttributedLabel.h"
#import "Flamey-Swift.h"

@interface FLFacebookUploadModalViewController : UIViewController <FBRequestConnectionDelegate>
@property (weak, nonatomic) IBOutlet UIButton *readyButton;
@property (weak, nonatomic) IBOutlet UIView *modalView;
@property (weak, nonatomic) IBOutlet UILabel *modalTitle;
@property (weak, nonatomic) IBOutlet SpringImageView *springLogo;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *bodyLabel;

@end
