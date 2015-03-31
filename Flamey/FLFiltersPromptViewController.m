//
//  FLFiltersPromptViewController.m
//  Stndout
//
//  Created by Shane Rogers on 3/30/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFiltersPromptViewController.h"
#import "Mixpanel.h"

// Helpers
#import "FLViewHelpers.h"

@interface FLFiltersPromptViewController ()

@end

@implementation FLFiltersPromptViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"loaded"
                                               }];

    [self styleModal];
    [self setReadyTitleCopy];
    [self styleLetMeKnowButton];
}

- (void)styleModal {
    _modalView.layer.cornerRadius = 10;
    _modalView.clipsToBounds = YES;
}

- (void)setReadyTitleCopy {
    _readyTitle.font = [UIFont fontWithName:@"Rochester" size:[FLViewHelpers titleCopyForScreenSize]];
}

- (void)styleLetMeKnowButton {
    [FLViewHelpers setBaseButtonStyle:_letMeKnowButton withColor:[UIColor whiteColor]];
    [_letMeKnowButton setBackgroundColor:[UIColor clearColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)close:(id)sender {
}

- (IBAction)letMeKnow:(id)sender {
}
@end
