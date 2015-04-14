//
//  FBLMemberListCell.h
//  Stndout
//
//  Created by Shane Rogers on 4/13/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

// Data Layer
#import "FBLMember.h"

@interface FBLMemberListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profileImage;
@property (weak, nonatomic) IBOutlet UILabel *name;
@property (weak, nonatomic) IBOutlet UILabel *email;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *status;
@property (weak, nonatomic) IBOutlet UILabel *timezone;

- (void)bindData:(FBLMember *)member;

@end
