//
//  FLTutorialProcessView.h
//  Flamey
//
//  Created by Shane Rogers on 3/21/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface FLTutorialProcessView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIView *firstSection;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *firstCopy;
@property (weak, nonatomic) IBOutlet UIImageView *firstImageView;
@property (weak, nonatomic) IBOutlet UIView *secondSection;
@property (weak, nonatomic) IBOutlet TTTAttributedLabel *secondCopy;
@property (weak, nonatomic) IBOutlet UIImageView *secondImageView;

- (void)setContent;
@end
