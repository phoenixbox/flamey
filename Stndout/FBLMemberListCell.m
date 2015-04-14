//
//  FBLMemberListCell.m
//  Stndout
//
//  Created by Shane Rogers on 4/13/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLMemberListCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation FBLMemberListCell

- (void)bindData:(FBLMember *)member {
    _profileImage.layer.cornerRadius = _profileImage.frame.size.width/2;
    _profileImage.layer.masksToBounds = YES;
    [_profileImage sd_setImageWithURL:[NSURL URLWithString:member.image72] placeholderImage:[UIImage imageNamed:@"Persona"]];

    [_name setText:member.realName];
    [_email setText:member.email];
    [_title setText:member.title];

    if (!member.status) {
        [_status setText:@"Away"];
    } else {
        [_status setText:member.status];
    }
    [_timezone setText:member.tzLabel];
}

- (void)layoutSubviews {
    _profileImage.layer.cornerRadius = _profileImage.frame.size.width/2;
    _profileImage.layer.masksToBounds = YES;
}

@end
