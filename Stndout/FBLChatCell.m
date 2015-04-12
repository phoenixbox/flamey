//
//  FBLChatCell.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChatCell.h"
#import "FBLHelpers.h"
#import "FBLAppConstants.h"
#import <ParseUI/ParseUI.h>

@interface FBLChatCell() {
    PFObject *chat;
}

@property (strong, nonatomic) IBOutlet PFImageView *imageUser;
@property (strong, nonatomic) IBOutlet UILabel *labelDescription;
@property (strong, nonatomic) IBOutlet UILabel *labelLastMessage;
@property (strong, nonatomic) IBOutlet UILabel *labelElapsed;
@property (strong, nonatomic) IBOutlet UILabel *labelCounter;

@end

@implementation FBLChatCell

@synthesize imageUser;
@synthesize labelDescription, labelLastMessage;
@synthesize labelElapsed, labelCounter;

- (void)bindData:(PFObject *)chat_ {
    chat = chat_;

    imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
    imageUser.layer.masksToBounds = YES;

    PFUser *lastUser = chat[PF_MESSAGES_LASTUSER];
    [imageUser setFile:lastUser[PF_USER_PICTURE]];
    [imageUser loadInBackground];

    labelDescription.text = chat[PF_MESSAGES_DESCRIPTION];
    labelLastMessage.text = chat[PF_MESSAGES_LASTMESSAGE];

    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:chat[PF_MESSAGES_UPDATEDACTION]];
    labelElapsed.text = TimeElapsed(seconds);

    int counter = [chat[PF_MESSAGES_COUNTER] intValue];
    labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new", counter];
}

@end

