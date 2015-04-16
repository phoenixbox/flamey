//
//  FBLChatsEmptyMessageView.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kChatToAnyone;
extern NSString *const kCreateSingleChat;

@interface FBLChatsEmptyMessageView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *emptyTitle;
@property (weak, nonatomic) IBOutlet UIButton *startAnyChat;
@property (weak, nonatomic) IBOutlet UIButton *startSpecificChat;
- (IBAction)createAnyoneChat:(id)sender;
- (IBAction)pickSomeoneToChatTo:(id)sender;

@end
