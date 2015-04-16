//
//  FBLMessageController.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Parse/Parse.h>
#import "FBLMember.h"

NSString*	StartPrivateChat			(PFUser *user1, PFUser *user2);
NSString*	StartMultipleChat			(NSMutableArray *users);

void		CreateMessageItem			(PFUser *user, NSString *groupId, NSString *description);
void		DeleteMessageItem			(PFObject *message);

void		UpdateMessageCounter		(NSString *groupId, NSString *lastMessage);
void		ClearMessageCounter			(NSString *groupId);
