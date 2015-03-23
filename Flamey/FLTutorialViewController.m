//
//  FLTutorialViewController.m
//  Flamey
//
//  Created by Shane Rogers on 3/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLTutorialViewController.h"
#import "FLTutorialSolutionView.h"
#import "FLTutorialHowView.h"
#import "FLTutorialResultView.h"
#import "FLTutorialProcessView.h"

// Helpers
#import "FLViewHelpers.h"

// Data Layer
#import "FLSettings.h"

static NSString * const kTutorialSolutionView = @"FLTutorialSolutionView";
static NSString * const kTutorialProcessView = @"FLTutorialProcessView";
static NSString * const kTutorialResultView = @"FLTutorialResultView";

static NSString * const kCompleteTutorial = @"completeTutorial";

@interface FLTutorialViewController ()

@end

@implementation FLTutorialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self listenForCompleteTrigger];
    [self listenForSolutionTrigger];
    [self listenForContinueTrigger];
    [self listenForProcessTrigger];
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
    UIView *newView;

    // Lib bug where the slides are not triggering the last view
    switch (index) {
        case 0:
            newView = [self prepareTutorialSolutionView];
            break;
        case 1:
            newView = [self prepareTutorialProcessView];
            break;
        case 2:
            newView = [self prepareTutorialResultView];
            break;
        default:
            NSLog(@"View Type Missing For Slide View");
            break;
    }

    view = newView;

    return view;
}

- (CGSize)swipeViewItemSize:(SwipeView *)swipeView
{
    return self.swipeView.bounds.size;
}

- (FLTutorialSolutionView *)prepareTutorialSolutionView {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kTutorialSolutionView owner:nil options:nil];
    FLTutorialSolutionView *solutionView = (FLTutorialSolutionView *)[nibContents lastObject];
    [solutionView setLabels];

    // TODO: Compose this specialized setup to its own function
    [FLViewHelpers setBaseButtonStyle:solutionView.finishButton withColor:[UIColor blackColor]];
    [solutionView.finishButton setHidden:YES];

    return solutionView;
}

- (FLTutorialProcessView *)prepareTutorialProcessView {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kTutorialProcessView owner:nil options:nil];
    FLTutorialProcessView *processView = (FLTutorialProcessView *)[nibContents lastObject];

    [processView setContent];
    // TODO: Compose this specialized setup to its own function

    return processView;
}

- (FLTutorialResultView *)prepareTutorialResultView {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kTutorialResultView owner:nil options:nil];
    FLTutorialResultView *resultView = (FLTutorialResultView *)[nibContents lastObject];

    [resultView setLabels];

    return resultView;
}

- (void)unwindToSelectedPhotos {
    FLSettings *settings = [FLSettings defaultSettings];
    [settings setSeenTutorial:YES];

    [self performSegueWithIdentifier:@"unwindToSelection" sender:self];
}

- (void)listenForCompleteTrigger {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(unwindToSelectedPhotos)
                   name:kCompleteTutorial
                 object:nil];
}

- (void)listenForSolutionTrigger {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(slideForward)
                   name:kCompleteSolutionTutorial
                 object:nil];

}

- (void)listenForProcessTrigger {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(slideForward)
                   name:kCompleteProcess
                 object:nil];
}

- (void)listenForContinueTrigger {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(unwindToSelectedPhotos)
                   name:kCompleteResult
                 object:nil];
}

- (void)slideForward {
    [_swipeView scrollByNumberOfItems:1 duration:0.5];
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
