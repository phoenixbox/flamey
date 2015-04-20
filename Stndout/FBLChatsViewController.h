//
//  FBLChatsViewController.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "FBLMemberListView.h"
#import <SocketRocket/SRWebSocket.h>

@interface FBLChatsViewController : UITableViewController <FBLMemberListDelegate, SRWebSocketDelegate>

- (void)loadChannels;

@end
