//
//  FLTutorialViewController.m
//  Flamey
//
//  Created by Shane Rogers on 3/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialViewController.h"
#import "FLTutorialSolutionView.h"
//#import "FLTutorialHowView.h"
//#import "FLTutorialReinforceView.h"

// Helpers
#import "FLViewHelpers.h"

static NSString * const kTutorialSolutionView = @"FLTutorialSolutionView";
static NSString * const kTutorialHowView = @"FLTutorialHowView";
static NSString * const kTutorialReinforceView = @"FLTutorialReinforceView";

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
    return 3;
}

- (UIView *)swipeView:(SwipeView *)swipeView viewForItemAtIndex:(NSInteger)index reusingView:(UIView *)view
{
    if (view == nil) {
        NSString *viewType;
        UIView *newView;

        switch (index) {
            case 0:
                newView = [self prepareTutorialSolutionView];
                break;
            case 1:
                newView = [self prepareTutorialSolutionView];
//                viewType = kTutorialSolutionView;
                break;
            case 2:
                newView = [self prepareTutorialSolutionView];
//                viewType = kTutorialSolutionView;
                break;
            default:
                NSLog(@"View Type Missing For Slide View");
                break;
        }

        view = newView;
    }

    return view;
}

- (FLTutorialSolutionView *)prepareTutorialSolutionView {
    NSString *viewType;
    viewType = kTutorialSolutionView;
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:viewType owner:nil options:nil];
    FLTutorialSolutionView *tutorialView = (FLTutorialSolutionView *)[nibContents lastObject];

    // TODO: Compose this specialized setup to its own function
    [FLViewHelpers setBaseButtonStyle:tutorialView.finishButton];
    [tutorialView.finishButton setHidden:YES];

    return tutorialView;
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
