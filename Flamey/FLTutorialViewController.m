//
//  FLTutorialViewController.m
//  Flamey
//
//  Created by Shane Rogers on 3/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialViewController.h"
#import "FLTutorialView.h"

static NSString * const kTutorialView = @"FLTutorialView";

@interface FLTutorialViewController ()

@end

@implementation FLTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self listenForUnwindTrigger];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark SwipeView methods

- (NSInteger)numberOfItemsInSwipeView:(SwipeView *)swipeView
{
    return 4;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil) {
        NSString *viewType;

        switch (index) {
            case 0:
                viewType = kTutorialView;
                break;
            case 1:
                viewType = kTutorialView;
                break;
            case 2:
                viewType = kTutorialView;
                break;
            case 3:
                viewType = kTutorialView;
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

- (void)unwindToSelectedPhotos {
    [self performSegueWithIdentifier:@"unwindToSelection" sender:self];
}

- (void)listenForUnwindTrigger {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(unwindToSelectedPhotos)
                   name:kCompleteTutorial
                 object:nil];
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
