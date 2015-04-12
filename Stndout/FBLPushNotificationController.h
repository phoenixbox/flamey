//
//  FBLPushNotificationController.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Parse/Parse.h>

#import "AppConstant.h"

#import "FBLPushNotification.h"

void ParsePushUserAssign(void) {
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[PF_INSTALLATION_USER] = [PFUser currentUser];
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"ParsePushUserAssign save error.");
         }
     }];
}

void ParsePushUserResign(void) {
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObjectForKey:PF_INSTALLATION_USER];
    [installation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"ParsePushUserResign save error.");
         }
     }];
}

void SendPushNotification(NSString *groupId, NSString *text) {
    PFUser *user = [PFUser currentUser];
    NSString *message = [NSString stringWithFormat:@"%@: %@", user[PF_USER_FULLNAME], text];

    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query whereKey:PF_MESSAGES_GROUPID equalTo:groupId];
    [query whereKey:PF_MESSAGES_USER notEqualTo:user];
    [query includeKey:PF_MESSAGES_USER];
    [query setLimit:1000];

    PFQuery *queryInstallation = [PFInstallation query];
    [queryInstallation whereKey:PF_INSTALLATION_USER matchesKey:PF_MESSAGES_USER inQuery:query];

    PFPush *push = [[PFPush alloc] init];
    [push setQuery:queryInstallation];
    [push setMessage:message];
    [push sendPushInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil)
         {
             NSLog(@"SendPushNotification send error.");
         }
     }];
}
