//
//  FLTutorialResultView.h
//  Flamey
//
//  Created by Shane Rogers on 3/19/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>
// TODO: Change when using
#import "Flamey-Swift.h"

extern NSString *const kCompleteResult;

@interface FLTutorialResultView : UIView

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *getMatchedTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *matchTitle;
@property (weak, nonatomic) IBOutlet UIView *profileContainer;
@property (weak, nonatomic) IBOutlet UIImageView *firstProfile;
@property (weak, nonatomic) IBOutlet SpringImageView *secondProfile;
@property (nonatomic, strong) UITapGestureRecognizer *matchViewTap;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *explanation;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

- (IBAction)start:(id)sender;
- (void)setLabels;

@end
