//
//  FBLFeedbackTabBarController.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLFeedbackTabBarController.h"

#import "FBLChatsViewController.h"
#import "FBLGroupsViewController.h"
#import "FBLProfileViewController.h"

@interface FBLFeedbackTabBarController ()

@property (nonatomic, strong) FBLGroupsViewController *groupsViewController;
@property (nonatomic, strong) FBLChatsViewController *messagesViewController;
@property (nonatomic, strong) FBLProfileViewController *profileViewController;
@property (nonatomic, strong) UINavigationBar *navigationBar;

@end

@implementation FBLFeedbackTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setFeedbackViewControllers];

    [[self navigationItem] setTitleView:nil];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    self.navigationItem.titleView = logoView;

    [self styleTabBar];
}

- (void)setFeedbackViewControllers {
    _groupsViewController = [[FBLGroupsViewController alloc] init];
    _messagesViewController = [[FBLChatsViewController alloc] init];
    _profileViewController = [[FBLProfileViewController alloc] init];

    UINavigationController *groupsNavController = [[UINavigationController alloc] initWithRootViewController:_groupsViewController];
    UINavigationController *messagesNavController = [[UINavigationController alloc] initWithRootViewController:_messagesViewController];
    UINavigationController *profileNavController = [[UINavigationController alloc] initWithRootViewController:_profileViewController];

    self.viewControllers = [NSArray arrayWithObjects:groupsNavController, messagesNavController, profileNavController, nil];
    self.tabBar.translucent = NO;
    self.selectedIndex = 1;
}

- (void)styleTabBar {
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];

    NSArray *tabBarImagesMap = @[@"Frame", @"Settings", @"Frame"];
    NSArray *tabBarTitlesMap = @[@"Groups", @"Chats", @"Profile"];

    [[self.tabBar items] enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger index, BOOL *stop){
        [self setTabItemImages:item withTitle:[tabBarTitlesMap objectAtIndex:index] andImageName:[tabBarImagesMap objectAtIndex:index]];
    }];
}

- (void)setTabItemImages:(UITabBarItem *)item withTitle:(NSString *)title andImageName:(NSString *)imageName {
    [item setTitle:title];

    [item setImage:[[UIImage imageNamed:[imageName stringByAppendingString:@"Deselected.png"]]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item setSelectedImage:[[UIImage imageNamed:[imageName stringByAppendingString:@"Selected.png"]]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] } forState:UIControlStateNormal];
    [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } forState:UIControlStateHighlighted];
    [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:12.0] } forState:UIControlStateNormal];
};

- (void)dismissFeedbackModal {
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
