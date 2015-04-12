//
//  FBLPushNotificationController.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Parse/Parse.h>

void		ParsePushUserAssign		(void);
void		ParsePushUserResign		(void);

void		SendPushNotification	(NSString *groupId, NSString *text);