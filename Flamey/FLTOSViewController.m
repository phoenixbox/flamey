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

- (void)viewDidLayoutSubviews {
    [self setHeaderLogo];
    [self setScrollPosition];
}

- (void)setScrollPosition {
    [_body setScrollsToTop:YES];
    [_body setContentOffset:CGPointMake(0.0, 0.0) animated:NO];
}

- (void)setHeaderLogo {
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    _navTitle.titleView = logoView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)back:(id)sender {
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
