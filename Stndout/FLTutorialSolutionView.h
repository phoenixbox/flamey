//
//  FLTutorialSolutionView.h
//  Flamey
//
//  Created by Shane Rogers on 3/4/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kCompleteSolutionTutorial;

extern NSString *const kMaleOneSelected;
extern NSString *const kMaleTwoSelected;
extern NSString *const kMaleThreeSelected;
extern NSString *const kFemaleOneSelected;
extern NSString *const kFemaleTwoSelected;
extern NSString *const kFemaleThreeSelected;

@interface FLTutorialSolutionView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *tutorialTitle;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

@property (weak, nonatomic) IBOutlet UIButton *firstPersonaButton;
- (IBAction)selectFirstPersona:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *secondPersonaButton;
- (IBAction)selectSecondPersona:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *thirdPersonaButton;
- (IBAction)selectThirdPersona:(id)sender;

- (IBAction)completeSolution:(id)sender;
- (void)setLabels;
@property (weak, nonatomic) IBOutlet UIButton *removeButton;
- (IBAction)exitTutorial:(id)sender;


@end