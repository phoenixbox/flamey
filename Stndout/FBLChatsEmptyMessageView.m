//
//  FBLChatsEmptyMessageView.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChatsEmptyMessageView.h"

NSString *const kChatToAnyone = @"chatToAnyone";
NSString *const kCreateSingleChat = @"createSingleChat";

@implementation FBLChatsEmptyMessageView

- (IBAction)createAnyoneChat:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:kChatToAnyone object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];

}

- (IBAction)pickSomeoneToChatTo:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:kCreateSingleChat object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
