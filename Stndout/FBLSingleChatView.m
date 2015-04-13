//
//  FBLSingleChatView.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import "FBLAppConstants.h"
#import "FBLSingleChatView.h"

@interface FBLSingleChatView()
{
    NSMutableArray *users;
}

@property (strong, nonatomic) IBOutlet UIView *viewHeader;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end

@implementation FBLSingleChatView

@synthesize delegate;
@synthesize viewHeader, searchBar;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Single Chat View";

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self
                                                                                          action:@selector(dismissView)];

    self.tableView.tableHeaderView = viewHeader;

    users = [[NSMutableArray alloc] init];

    [self loadUsers];
}

#pragma mark - Backend methods

- (void)loadUsers
{
    PFUser *user = [PFUser currentUser];

    // TODO: Use the Users from the Slack store

    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];

    [query whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
    [query orderByAscending:PF_USER_FULLNAME];
    [query setLimit:1000];

    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
         if (error == nil)
         {
             [users removeAllObjects];
             [users addObjectsFromArray:objects];
             [self.tableView reloadData];
         }
         else {
             // TODO
             NSLog(@"%@: Loading Users Error", NSStringFromClass([self class]));
         }
     }];
}

- (void)searchUsers:(NSString *)search_lower
{
    PFUser *user = [PFUser currentUser];

    PFQuery *query = [PFQuery queryWithClassName:PF_USER_CLASS_NAME];
    [query whereKey:PF_USER_OBJECTID notEqualTo:user.objectId];
    [query whereKey:PF_USER_FULLNAME_LOWER containsString:search_lower];
    [query orderByAscending:PF_USER_FULLNAME];
    [query setLimit:1000];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             [users removeAllObjects];
             [users addObjectsFromArray:objects];
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [users count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    PFUser *user = users[indexPath.row];
    cell.textLabel.text = user[PF_USER_FULLNAME];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    [self dismissViewControllerAnimated:YES completion:^{
        if (delegate != nil) {
            [delegate didSelectSingleUser:users[indexPath.row]];
        }
    }];
}

#pragma mark - UISearchBarDelegate

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([searchText length] > 0)
    {
        [self searchUsers:[searchText lowercaseString]];
    }
    else [self loadUsers];
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
    
    [self loadUsers];
}

@end
