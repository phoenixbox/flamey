//
//  FBLLoginViewController.h
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FBLLoginViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *loginPromptTitle;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
- (IBAction)facebookButton:(id)sender;

@end
