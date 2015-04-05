//
//  FLTOSViewController.h
//  Flamey
//
//  Created by Shane Rogers on 2/21/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "Mixpanel.h"

@interface FLTOSViewController : UIViewController <UITextViewDelegate, UIScrollViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *termsTitle;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextView *body;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;
- (IBAction)back:(id)sender;

@end