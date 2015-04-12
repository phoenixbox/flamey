//
//  FBLSingleChatView.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Parse/Parse.h>

@protocol FBLSingleChatDelegate

- (void)didSelectSingleUser:(PFUser *)user;

@end

@interface FBLSingleChatView : UITableViewController <UISearchBarDelegate>

@property (nonatomic, assign) IBOutlet id<FBLSingleChatDelegate>delegate;

@end
