//
//  FBLChatsViewController.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChatsViewController.h"
#import "FBLChatViewController.h"

#import "FBLSingleChatView.h"
#import "FBLAppConstants.h"
#import "FBLMessageController.h"
#import "FBLHelpers.h"
#import "FBLChatCell.h"
#import <Parse/Parse.h>

NSString *const kChatCellIdentifier = @"FBLChatCell";

@interface FBLChatsViewController ()

@property (nonatomic, strong) NSMutableArray *chats;

@end

@implementation FBLChatsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self styleNavigationBar];
    [self setupTable];
    [self styleTableView];
}

- (void)setupTable {
    [self.tableView registerNib:[UINib nibWithNibName:kChatCellIdentifier bundle:nil] forCellReuseIdentifier:kChatCellIdentifier];

    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(loadChats) forControlEvents:UIControlEventValueChanged];

    _chats = [[NSMutableArray alloc] init];
}

- (void)styleNavigationBar {
    [[self navigationItem] setTitleView:nil];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    self.navigationItem.titleView = logoView;

    UIImage *removeIcon = [UIImage imageNamed:@"removeIcon.png"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:removeIcon landscapeImagePhone:removeIcon style:UIBarButtonItemStylePlain target:self action:@selector(closeFeedback)];
    [self.navigationItem.leftBarButtonItem setTintColor:[UIColor blackColor]];

    UIImage *addIcon = [UIImage imageNamed:@"addIcon.png"];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:addIcon landscapeImagePhone:removeIcon style:UIBarButtonItemStylePlain target:self action:@selector(createSingleChat)];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor blackColor]];
}

-(void)styleTableView {
    [self.tableView setBackgroundColor:[UIColor whiteColor]];
}

- (void)closeFeedback {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // NEED SOME CONTEXT OF CURRENT USER
    if ([PFUser currentUser] != nil)
    {
        [self loadChats];
    }

    else LoginUser(self);
}

#pragma mark - Backend methods

- (void)loadChats
{
    PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGES_CLASS_NAME];
    [query whereKey:PF_MESSAGES_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_MESSAGES_LASTUSER];
    [query orderByDescending:PF_MESSAGES_UPDATEDACTION];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
     {
         if (error == nil)
         {
             // Add models to the table view collection
             [_chats removeAllObjects];
             [_chats addObjectsFromArray:objects];
             [self.tableView reloadData];
             [self updateTabCounter];
         }
         else {
             NSLog(@"%@: Loading Chats Error", NSStringFromClass([self class]));
         }

         [self.refreshControl endRefreshing];
     }];
}

#pragma mark - Helper methods

- (void)updateTabCounter
{
    int total = 0;
    for (PFObject *message in _chats)
    {
        total += [message[PF_MESSAGES_COUNTER] intValue];
    }
    UITabBarItem *item = self.tabBarController.tabBar.items[1];
    item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions

- (void)createSingleChat {
    FBLSingleChatView *singleChatView = [[FBLSingleChatView alloc] init];
    singleChatView.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:singleChatView];
    [self presentViewController:navController animated:YES completion:nil];
}

- (void)startChat:(NSString *)channelId {
    FBLChatViewController *chatViewController = [[FBLChatViewController alloc] initWithSlackChannel:channelId];
    chatViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:chatViewController animated:YES];
}

- (void)actionCleanup
{
    [_chats removeAllObjects];
    [self.tableView reloadData];
    [self updateTabCounter];
}

#pragma mark - FBLSingleChatDelegate

- (void)didSelectSingleUser:(PFUser *)user2 {

    PFUser *user1 = [PFUser currentUser];
    NSString *groupId = StartPrivateChat(user1, user2);

    [self startChat:groupId];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_chats count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBLChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FBLChatCell" forIndexPath:indexPath];
    [cell bindData:_chats[indexPath.row]];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    DeleteMessageItem(_chats[indexPath.row]);
    [_chats removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    [self updateTabCounter];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    PFObject *message = _chats[indexPath.row];
    [self startChat:message[PF_MESSAGES_GROUPID]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
