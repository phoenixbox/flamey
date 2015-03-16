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
                newView = [self prepareTutorialHowView];
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
    FLTutorialSolutionView *solutionView = (FLTutorialSolutionView *)[nibContents lastObject];

    // TODO: Compose this specialized setup to its own function
    [FLViewHelpers setBaseButtonStyle:solutionView.finishButton withColor:[UIColor blackColor]];
    [solutionView.finishButton setHidden:YES];

    return solutionView;
}

- (FLTutorialHowView *)prepareTutorialHowView {
    NSString *viewType;
    viewType = kTutorialHowView;
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:viewType owner:nil options:nil];
    FLTutorialHowView *howView = (FLTutorialHowView *)[nibContents lastObject];

    [FLViewHelpers setBaseButtonStyle:howView.continueButton withColor:[UIColor blackColor]];
    [howView.continueButton setHidden:YES];

    [howView.userCharacterImageView setContentMode:UIViewContentModeScaleAspectFit];
    [howView.uploadProcessImageView setContentMode:UIViewContentModeScaleAspectFit];
    // Rename this to dating image view context
    [howView.thirdSectionImageView setContentMode:UIViewContentModeScaleAspectFit];


    // TODO: Compose this specialized setup to its own function
//    [FLViewHelpers setBaseButtonStyle:tutorialView.finishButton withColor:[UIColor blackColor]];
//    [tutorialView.finishButton setHidden:YES];

    return howView;
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
               selector:@selector(slideForward)
                   name:kCompleteTutorial
                 object:nil];
}

- (void)listenForContinueTrigger {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(slideForward)
                   name:kContinueTutorial
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
