//
//  FLTOSViewController.m
//  Flamey
//
//  Created by Shane Rogers on 2/21/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTOSViewController.h"

@interface FLTOSViewController ()

@end

@implementation FLTOSViewController

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

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];

}
@end