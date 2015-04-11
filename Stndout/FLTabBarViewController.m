//
//  FLTabBarViewController.m
//  Flamey
//
//  Created by Shane Rogers on 3/14/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTabBarViewController.h"

@interface FLTabBarViewController ()

@end

@implementation FLTabBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self styleTabBar];
}

- (void)styleTabBar {
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    [[UITabBar appearance] setTintColor:[UIColor blackColor]];

    NSArray *tabBarImagesMap = @[@"Frame", @"Settings"];

    [[self.tabBar items] enumerateObjectsUsingBlock:^(UITabBarItem *item, NSUInteger index, BOOL *stop){
        [self setTabItemImages:item forImageName:[tabBarImagesMap objectAtIndex:index]];
    }];
}

- (void)setTabItemImages:(UITabBarItem *)item forImageName:(NSString *)imageName {
    [item setImage:[[UIImage imageNamed:[imageName stringByAppendingString:@"Deselected.png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item setSelectedImage:[[UIImage imageNamed:[imageName stringByAppendingString:@"Selected.png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
    [item setTitleTextAttributes:@{
                                   NSForegroundColorAttributeName : [UIColor grayColor],
                                   NSFontAttributeName: [UIFont fontWithName:@"AvenirNext-Regular" size:12.0]
                                   }
                        forState:UIControlStateNormal];

    [item setTitleTextAttributes:@{ NSForegroundColorAttributeName : [UIColor blackColor] } forState:UIControlStateHighlighted];
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
