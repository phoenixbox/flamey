//
//  FLTOSViewController.h
//  Flamey
//
//  Created by Shane Rogers on 2/21/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLTOSViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *termsTitle;
@property (weak, nonatomic) IBOutlet UITextView *body;
- (IBAction)back:(id)sender;

@end