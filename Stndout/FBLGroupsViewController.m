//
//  FBLGroupsViewController.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLGroupsViewController.h"

@interface FBLGroupsViewController ()

@end

@implementation FBLGroupsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
   [self styleNavigationBar];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)styleNavigationBar {
    [[self navigationItem] setTitleView:nil];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    self.navigationItem.titleView = logoView;

    UIImage *removeIcon = [UIImage imageNamed:@"removeIcon.png"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:removeIcon landscapeImagePhone:removeIcon style:UIBarButtonItemStylePlain target:self action:@selector(closeFeedback)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blackColor]];
}

- (void)closeFeedback {
    [self dismissViewControllerAnimated:YES completion:nil];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
