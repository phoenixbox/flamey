//
//  FLTutorialViewController.m
//  Flamey
//
//  Created by Shane Rogers on 3/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialViewController.h"

static NSString * const kTutorialFirst = @"FLTutorialFirst";

@interface FLTutorialViewController ()

@end

@implementation FLTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SwipeView methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 3;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil) {
        NSString *viewType;

        switch (index) {
            case 0:
                viewType = kTutorialFirst;
                break;
            case 1:
                viewType = kTutorialFirst;
                break;
            case 2:
                viewType = kTutorialFirst;
                break;
            default:
                NSLog(@"View Type Missing For Slide View");
                break;
        }

        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:viewType owner:nil options:nil];
        view = [nibContents lastObject];
    }


    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
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
