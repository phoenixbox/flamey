//
//  FLTutorialView.h
//  Flamey
//
//  Created by Shane Rogers on 3/4/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kCompleteTutorial;

@interface FLTutorialView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *tutorialTitle;
@property (weak, nonatomic) IBOutlet UIImageView *tutorialImageView;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;

- (IBAction)finishTutorial:(id)sender;
@end
