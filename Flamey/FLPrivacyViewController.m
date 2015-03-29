//
//  FLPrivacyViewController.m
//  Flamey
//
//  Created by Shane Rogers on 3/28/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLPrivacyViewController.h"

@implementation FLPrivacyViewController

- (void)viewDidLayoutSubviews {
    [self setHeaderLogo];
    [self setScrollPosition];
}

- (void)setHeaderLogo {
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    _titleBar.titleView = logoView;
}

- (void)setScrollPosition {
    [_privacyPolicyBody setScrollsToTop:YES];
    [_privacyPolicyBody setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
