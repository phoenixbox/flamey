//
//  ChatViewController.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

// Libs
#import "JSQMessages.h"
#import <SocketRocket/SRWebSocket.h>

@interface FBLChatViewController : JSQMessagesViewController <SRWebSocketDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) void (^popWindow)();

@end
