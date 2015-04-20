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
#import "FBLChannel.h"
#import <ParseUI/ParseUI.h>

@interface FBLChatCell() {
    FBLChannel *channel;
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

// TODO: Change the domain model of chat to channel
// Leverage channel member id list to get images from parse
- (void)bindData:(FBLChannel *)channel_ {
    channel = channel_;

    imageUser.layer.cornerRadius = imageUser.frame.size.width/2;
    imageUser.layer.masksToBounds = YES;

    PFUser *lastUser = [PFUser currentUser];
    [imageUser setFile:lastUser[PF_CUSTOMER_PICTURE]];
    [imageUser loadInBackground];

    labelDescription.text = channel.name;
    NSDate *dateStamp = [NSDate dateWithTimeIntervalSince1970:
                         [channel.lastRead doubleValue]];
    NSTimeInterval seconds = [[NSDate date] timeIntervalSinceDate:dateStamp];
    labelElapsed.text = TimeElapsed(seconds);

    int counter = [channel.unreadCount intValue];
    labelCounter.text = (counter == 0) ? @"" : [NSString stringWithFormat:@"%d new", counter];
}

@end