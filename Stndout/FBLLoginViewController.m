//
//  FBLLoginViewController.m
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLLoginViewController.h"
#import "AFNetworking.h"
#import "FBLAppConstants.h"
#import "FBLHelpers.h"

@interface FBLLoginViewController ()

@end

@implementation FBLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
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

- (IBAction)registerCustomerDetails:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end