//
//  FBLMemberListView.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Parse/Parse.h>

@protocol FBLMemberListDelegate

- (void)didSelectSingleUser:(PFUser *)user;

@end

@interface FBLMemberListView : UITableViewController <UISearchBarDelegate>

@property (nonatomic, assign) IBOutlet id<FBLMemberListDelegate>delegate;

@end
