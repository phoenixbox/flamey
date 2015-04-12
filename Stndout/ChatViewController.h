//
//  ChatViewController.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "JSQMessages.h"

@interface ChatViewController : JSQMessagesViewController <UIActionSheetDelegate, UIImagePickerControllerDelegate>

- (id)initWithSlackChannel:(NSString *)channelId;

@end
