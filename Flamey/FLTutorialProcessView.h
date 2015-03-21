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

- (void)setContent;
@end
