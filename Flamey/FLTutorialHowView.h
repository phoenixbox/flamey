//
//  FLTutorialHowView.h
//  Flamey
//
//  Created by Shane Rogers on 3/8/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kContinueTutorial;

@interface FLTutorialHowView : UIView

@property (weak, nonatomic) IBOutlet UIView *firstSection;
@property (weak, nonatomic) IBOutlet UILabel *firstSectionCopy;
@property (weak, nonatomic) IBOutlet UIImageView *userCharacterImageView;

@property (weak, nonatomic) IBOutlet UIView *secondSection;
@property (weak, nonatomic) IBOutlet UILabel *sectionSectionCopy;
@property (weak, nonatomic) IBOutlet UIImageView *uploadProcessImageView;

@property (weak, nonatomic) IBOutlet UIView *thirdSection;
@property (weak, nonatomic) IBOutlet UILabel *thirdSectionCopy;
@property (weak, nonatomic) IBOutlet UIImageView *thirdSectionImageView;

@property (weak, nonatomic) IBOutlet UIButton *continueButton;
- (IBAction)continue:(id)sender;

@end
