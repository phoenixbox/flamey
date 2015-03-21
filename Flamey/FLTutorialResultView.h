//
//  FLTutorialResultView.h
//  Flamey
//
//  Created by Shane Rogers on 3/19/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TTTAttributedLabel/TTTAttributedLabel.h>

@interface FLTutorialResultView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (weak, nonatomic) IBOutlet UILabel *getMatchedTitle;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *matchTitle;
@property (weak, nonatomic) IBOutlet UIView *profileContainer;
@property (weak, nonatomic) IBOutlet UIImageView *firstProfile;
@property (weak, nonatomic) IBOutlet UIImageView *secondProfile;

@property (weak, nonatomic) IBOutlet TTTAttributedLabel *explanation;
- (void)setLabels;

@end
