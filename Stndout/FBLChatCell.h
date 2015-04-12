//
//  FBLChatCell.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface FBLChatCell : UITableViewCell

- (void)bindData:(PFObject *)chat_;

@end
