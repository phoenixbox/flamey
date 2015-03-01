//
//  FBSaveModalViewController.h
//  Flamey
//
//  Created by Shane Rogers on 2/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface FLFacebookUploadModalViewController : UIViewController <FBRequestConnectionDelegate>
@property (weak, nonatomic) IBOutlet UIButton *readyButton;

@end
