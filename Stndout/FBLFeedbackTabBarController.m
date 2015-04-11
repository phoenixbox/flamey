//
//  FBLFeedbackTabBarController.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLFeedbackTabBarController.h"

#import "FBLMessagesViewController.h"
#import "FBLGroupsViewController.h"
#import "FBLProfileViewController.h"

@interface FBLFeedbackTabBarController ()

@property (nonatomic, strong) FBLGroupsViewController *groupsViewController;
@property (nonatomic, strong) FBLMessagesViewController *messagesViewController;
@property (nonatomic, strong) FBLProfileViewController *profileViewController;

@end

@implementation FBLFeedbackTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self setFeedbackViewControllers];
    [self styleTabBar];
}

- (void)setFeedbackViewControllers {
    _groupsViewController = [[FBLGroupsViewController alloc] init];
    _messagesViewController = [[FBLMessagesViewController alloc] init];
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

    [[self.tabBar items] enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger index, BOOL *stop){
        [self setTabItemImages:item forImageName:[tabBarImagesMap objectAtIndex:index]];
    }];
}

- (void)setTabItemImages:(UITabBarItem *)item forImageName:(NSString *)imageName {
    [item setImage:[[UIImage imageNamed:[imageName stringByAppendingString:@"Deselected.png"]]
                    imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item setSelectedImage:[[UIImage imageNamed:[imageName stringByAppendingString:@"Selected.png"]]
                            imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor grayColor] } forState:UIControlStateNormal];
    [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } forState:UIControlStateHighlighted];
    [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor grayColor], NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:12.0] } forState:UIControlStateNormal];
};

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
