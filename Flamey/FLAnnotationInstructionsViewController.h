//
//  FLAnnotationInstructionsViewController.h
//  Flamey
//
//  Created by Shane Rogers on 3/27/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Flamey-Swift.h"

@interface FLAnnotationInstructionsViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIView *modalView;
@property (weak, nonatomic) IBOutlet UILabel *tapTitle;
@property (weak, nonatomic) IBOutlet UILabel *instructions;
@property (weak, nonatomic) IBOutlet UIView *touchView;
@property (weak, nonatomic) IBOutlet SpringImageView *markerLogo;
@property (weak, nonatomic) IBOutlet SpringImageView *handIcon;
@property (weak, nonatomic) IBOutlet UIButton *continueButton;
@property (weak, nonatomic) IBOutlet UIButton *closeButton;
- (IBAction)closeModal:(id)sender;
- (IBAction)continue:(id)sender;

@end
