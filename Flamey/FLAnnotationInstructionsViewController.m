//
//  FLAnnotationInstructionsViewController.m
//  Flamey
//
//  Created by Shane Rogers on 3/27/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLAnnotationInstructionsViewController.h"

// Data Layer
#import "FLSettings.h"

// Libs
#import "FLViewHelpers.h"

@interface FLAnnotationInstructionsViewController ()

@property (nonatomic, strong) UITapGestureRecognizer *touchViewTap;

@end

@implementation FLAnnotationInstructionsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self styleModal];
    [self styleContinueButton];
    [self setupTouchViewTapRecognizer];
}

- (void)setupTouchViewTapRecognizer {
    _touchViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(handleTap:)];
    _touchViewTap.numberOfTouchesRequired = 1;
    _touchViewTap.numberOfTapsRequired = 1;

    [_touchView addGestureRecognizer:_touchViewTap];
    _touchView.userInteractionEnabled = YES;
}

- (void)handleTap:(UITapGestureRecognizer *)gesture {
    [self simulateTouchAnimation];
    [self performSelector:@selector(simulateTouchResponse) withObject:nil afterDelay:0.2];
}

- (void)simulateTouchAnimation {
    [_handIcon setAnimation:@"pop"];
    [_handIcon setCurve:@"linear"];
    [_handIcon setForce:1];
    [_handIcon setDuration:0.5];
    [_handIcon animateTo];
}

- (void)simulateTouchResponse {
    [_markerLogo setAnimation:@"pop"];
    [_markerLogo setCurve:@"linear"];
    [_markerLogo setForce:1];
    [_markerLogo setContentScaleFactor:0.5];
    [_markerLogo setDuration:0.2];
    [_markerLogo animateTo];
}

- (void)styleModal {
    _modalView.layer.cornerRadius = 10;
    _modalView.clipsToBounds = YES;
}

- (void)styleContinueButton {
    [FLViewHelpers setBaseButtonStyle:_continueButton withColor:[UIColor whiteColor]];
    [_continueButton setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidLayoutSubviews {
    [_handIcon setAnimation:@"pop"];
    [_handIcon setCurve:@"linear"];
    [_handIcon setForce:1];
    [_handIcon setDuration:0.5];
    [_handIcon performSelector:@selector(animate) withObject:nil afterDelay:0.25];
}

- (void)understandAndMove {
    FLSettings *settings = [FLSettings defaultSettings];
    [settings setUnderstandAnnotation:YES];
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)continue:(id)sender {
    [self understandAndMove];
}

- (IBAction)closeModal:(id)sender {
    [self understandAndMove];
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
