//
//  FLFiltersPromptViewController.h
//  Stndout
//
//  Created by Shane Rogers on 3/30/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface FLFiltersPromptViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *modalView;
@property (weak, nonatomic) IBOutlet UILabel *readyTitle;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *firstLabel;
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *secondLabel;
@property (weak, nonatomic) IBOutlet UIButton *letMeKnowButton;
- (IBAction)close:(id)sender;
- (IBAction)letMeKnow:(id)sender;

@end
