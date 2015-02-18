//
//  SecondViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLSettingsViewController.h"
#import "FLSettings.h"

@interface FLSettingsViewController ()

@end

@implementation FLSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)logOut:(id)sender {
    [FBSession.activeSession closeAndClearTokenInformation];
    [FLSettings defaultSettings].shouldSkipLogin = NO;
    [FLSettings defaultSettings].needToLogin = YES;
    [self performSegueWithIdentifier:@"logOut" sender:self];
}

@end
