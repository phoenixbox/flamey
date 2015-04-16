//
//  FBLMemberListView.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

// Libs
#import <Parse/Parse.h>
#import "MBProgressHUD.h"

// Constants
#import "FBLAppConstants.h"

// Data Layer
#import "FBLMember.h"
#import "FBLMembersStore.h"

// Components
#import "FBLMemberListView.h"
#import "FBLMemberListCell.h"

NSString *const kMemberCellIdentifier = @"FBLMemberListCell";

@interface FBLMemberListView()

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FBLMemberListView

@synthesize delegate;
@synthesize viewHeader, searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Single Chat View";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                                                          action:@selector(dismissView)];
    // Whats the craic here
    self.tableView.tableHeaderView = viewHeader;
    [self.tableView registerNib:[UINib nibWithNibName:kMemberCellIdentifier bundle:nil] forCellReuseIdentifier:kMemberCellIdentifier];

    [self loadMembers];
}

#pragma mark - Backend methods

- (void)loadMembers
{
//    PFUser *user = [PFUser currentUser];
    // TODO: Set a spinner active
    void(^completionBlock)(NSError *err)=^(NSError *error){
        if (error == nil) {
            // TODO: Turn off the spinner
            [self.tableView reloadData];
        }
        else {
            NSLog(@"%@: Loading Users Error", NSStringFromClass([self class]));
        }
    };

    [[FBLMembersStore sharedStore] fetchMembersWithCompletion:completionBlock];
}

- (void)searchUsers:(NSString *)search_lower
{
    PFUser *user = [PFUser currentUser];
    FBLMembersStore *membersStore = [FBLMembersStore sharedStore];

    PFQuery *query = [PFQuery queryWithClassName:PF_CUSTOMER_CLASS_NAME];
    [query whereKey:PF_CUSTOMER_OBJECTID notEqualTo:user.objectId];
    [query whereKey:PF_CUSTOMER_FULLNAME_LOWER containsString:search_lower];
    [query orderByAscending:PF_CUSTOMER_FULLNAME];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             [membersStore.members removeAllObjects];
             [membersStore.members addObjectsFromArray:objects];
             [self.tableView reloadData];
         }
         else {
              NSLog(@"%@: Searching Users Error", NSStringFromClass([self class]));
         }
     }];
}

#pragma mark - User actions
- (void)dismissView {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    FBLMembersStore *membersStore = [FBLMembersStore sharedStore];
    NSUInteger count = [membersStore.members count];

    if (count > 0) {
        [self.tableView.backgroundView setHidden:YES];
    } else {
        [self.tableView.backgroundView setHidden:NO];
    }

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FBLMembersStore *membersStore = [FBLMembersStore sharedStore];
    FBLMemberListCell *cell = [tableView dequeueReusableCellWithIdentifier:kMemberCellIdentifier forIndexPath:indexPath];
    FBLMember *member = membersStore.members[indexPath.row];
    [cell bindData:member];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FBLMembersStore *membersStore = [FBLMembersStore sharedStore];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self dismissViewControllerAnimated:YES completion:^{
        if (delegate != nil) {
            [delegate didSelectMember:membersStore.members[indexPath.row]];
        }
    }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70.0;
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0)
    {
        [self searchUsers:[searchText lowercaseString]];
    }

    else [self loadMembers];
}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar_
{
    [searchBar_ setShowsCancelButton:YES animated:YES];
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar_
{
    [searchBar_ setShowsCancelButton:NO animated:YES];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar_
{
    [self searchBarCancelled];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar_
{
    [searchBar_ resignFirstResponder];
}

- (void)searchBarCancelled
{
    searchBar.text = @"";
    [searchBar resignFirstResponder];
    
    [self loadMembers];
}

@end
