//
//  FBLMessageController.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLAppConstants.h"
#import "FBLMessageController.h"

// Data Layer
#import "FBLMember.h"

NSString *StartPrivateChat(PFUser *user1, PFUser *user2) {
    NSString *id1 = user1.objectId;
    NSString *id2 = user2.objectId;

    NSString *groupId = ([id1 compare:id2] < 0) ? [NSString stringWithFormat:@"%@%@", id1, id2] : [NSString stringWithFormat:@"%@%@", id2, id1];

    CreateMessageItem(user1, groupId, user2[PF_CUSTOMER_FULLNAME]);
    CreateMessageItem(user2, groupId, user1[PF_CUSTOMER_FULLNAME]);

    return groupId;
}

void CreateMessageItem(PFUser *user, NSString *groupId, NSString *description) {
    // Persist to Parse the
//    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
//    [query whereKey:PF_CHAT_USER equalTo:user];
//    [query whereKey:PF_CHAT_GROUPID equalTo:groupId];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//
//     {
//         if (error == nil)
//         {
//             if ([objects count] == 0)
//             {
//                 PFObject *message = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
//                 message[PF_CHAT_USER] = user;
//                 message[PF_CHAT_GROUPID] = groupId;
//                 message[PF_CHAT_DESCRIPTION] = description;
//                 message[PF_CHAT_LASTUSER] = [PFUser currentUser];
//                 message[PF_CHAT_LASTMESSAGE] = @"";
//                 message[PF_CHAT_COUNTER] = @0;
//                 message[PF_CHAT_UPDATEDACTION] = [NSDate date];
//                 [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                     if (error != nil) {
//                         NSLog(@"FBLMessageController: CreateMessageItem save error.");
//                     }
//                  }];
//             }
//         }
//         else NSLog(@"CreateMessageItem query error.");
//     }];
}

void DeleteMessageItem(PFObject *message) {
    [message deleteInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error != nil) {
             NSLog(@"FBLMessageController: DeleteMessageItem delete error.");
         }
     }];
}

void UpdateMessageCounter(NSString *groupId, NSString *lastMessage) {
//    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
//    [query whereKey:PF_CHAT_GROUPID equalTo:groupId];
//    [query setLimit:1000];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (error == nil)
//         {
//             for (PFObject *message in objects)
//             {
//                 PFUser *user = message[PF_CHAT_USER];
//                 if ([user.objectId isEqualToString:[PFUser currentUser].objectId] == NO)
//                     [message incrementKey:PF_CHAT_COUNTER byAmount:@1];
//
//                 message[PF_CHAT_LASTUSER] = [PFUser currentUser];
//                 message[PF_CHAT_LASTMESSAGE] = lastMessage;
//                 message[PF_CHAT_UPDATEDACTION] = [NSDate date];
//                 [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//                  {
//                      if (error != nil) {
//                          NSLog(@"FBLMessageController: UpdateMessageCounter save error.");
//                      }
//                  }];
//             }
//         }
//         else  {
//           NSLog(@"FBLMessageController: UpdateMessageCounter query error");
//         }
//     }];
}

void ClearMessageCounter(NSString *groupId) {
//    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
//    [query whereKey:PF_CHAT_GROUPID equalTo:groupId];
//    [query whereKey:PF_CHAT_USER equalTo:[PFUser currentUser]];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
//     {
//         if (error == nil)
//         {
//             for (PFObject *message in objects)
//             {
//                 message[PF_CHAT_COUNTER] = @0;
//                 [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//                  {
//                      if (error != nil) {
//                          NSLog(@"FBLMessageController: ClearMessageCounter save error.");
//                      }
//                  }];
//             }
//         }
//         else {
//             NSLog(@"FBLMessageController: ClearMessageCounter query error.");
//         }
//     }];
}
