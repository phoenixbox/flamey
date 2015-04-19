//
//  FBLChatsViewController.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChatsViewController.h"
#import "FBLChatsEmptyMessageView.h"

#import "FBLChatViewController.h"
#import "FBLViewHelpers.h"

#import "FBLMemberListView.h"
#import "FBLAppConstants.h"
#import "FBLMessageController.h"
#import "FBLHelpers.h"
#import "FBLChatCell.h"
#import <Parse/Parse.h>

// Data Layer
#import "FBLChannelStore.h"
#import "FBLSlackStore.h"

#import "FBLLoginViewController.h"
#import "AFBlurSegue.h"
static NSString * const kFBLLoginViewController = @"FBLLoginViewController";

NSString *const kChatCellIdentifier = @"FBLChatCell";
NSString *const kChatsEmptyMessageView = @"FBLChatsEmptyMessageView";

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

    // Setup Listeners
    [self setupListeners];

    // Setup Websocket Regardless
    [self setupWebsocket];

    // If there is no currentUser - Prompt to login
    if (![PFUser currentUser]) {
        [self showContactDetailsModal];
    }
}

- (void)setupWebsocket {
    void(^completionBlock)(NSError *error)=^(NSError *error) {
        if (error == nil) {
            NSString *websocketUrl = [FBLSlackStore sharedStore].webhookUrl;

            SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:websocketUrl]];
            newWebSocket.delegate = self;

            [newWebSocket open];

            NSLog(@"TODO: enable/disabled UI elements based on local collection availability");
        } else {
            SIAlertView *alert = [FBLViewHelpers createAlertForError:nil
                                                           withTitle:@"Ooops!" andMessage:@"We had trouble connecting to that channel"];
            [alert show];
        }
    };

    [[FBLSlackStore sharedStore] setupWebhook:completionBlock];
}

- (void)showContactDetailsModal {
    FBLLoginViewController *loginViewController = [[FBLLoginViewController alloc] init];

    loginViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;

    AFBlurSegue *segue = [[AFBlurSegue alloc] initWithIdentifier:@"FeedbackLoginSegue" source:self destination:loginViewController];
    [segue perform];
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

    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kChatsEmptyMessageView owner:nil options:nil];
    FBLChatsEmptyMessageView *emptyMessage = [nibContents lastObject];

    emptyMessage.contentView.layer.cornerRadius = 4;
    emptyMessage.contentView.layer.borderWidth = 1;
    emptyMessage.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    [emptyMessage.contentView setBackgroundColor:[UIColor whiteColor]];

    [FBLViewHelpers setBaseButtonStyle:emptyMessage.startAnyChat withColor:[UIColor blackColor]];
    [self.tableView setBackgroundView:emptyMessage];

    [FBLViewHelpers setBaseButtonStyle:emptyMessage.startSpecificChat withColor:[UIColor blackColor]];
    [self.tableView setBackgroundView:emptyMessage];
    // Show empty message by default
    [self.tableView.backgroundView setHidden:NO];
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
    PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
    [query whereKey:PF_CHAT_USER equalTo:[PFUser currentUser]];
    [query includeKey:PF_CHAT_LASTUSER];
    [query orderByDescending:PF_CHAT_UPDATEDACTION];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
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
        total += [message[PF_CHAT_COUNTER] intValue];
    }
    UITabBarItem *item = self.tabBarController.tabBar.items[1];
    item.badgeValue = (total == 0) ? nil : [NSString stringWithFormat:@"%d", total];
}

#pragma mark - User actions

- (void)createSingleChat {
    FBLMemberListView *singleChatView = [[FBLMemberListView alloc] init];
    singleChatView.delegate = self;
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:singleChatView];
    [self presentViewController:navController animated:YES completion:nil];
}

// create the slack channel
// success then join with the id
- (void)createAnyoneChat {

    void(^completionBlock)(NSString *channelId, NSString *createAnyoneError)=^(NSString *channelId, NSString *createAnyoneError){
        if (createAnyoneError == nil) {
            FBLChatViewController *chatViewController = [[FBLChatViewController alloc] initWithSlackChannel:channelId];
            chatViewController.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:chatViewController animated:YES];
        }
        else {
            // Trigger a selector based on the error type
            NSLog(@"Trigger a selector based on the error type");
        }
    };

    [[FBLChannelStore sharedStore] joinCurrentUserChannel:completionBlock];
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
// Triggered from member list view - alternate to a messaging pattern?
- (void)didSelectMember:(PFUser *)user2 {

    PFUser *user1 = [PFUser currentUser];
    NSString *groupId = StartPrivateChat(user1, user2);

    [self startChat:groupId];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSUInteger count = [_chats count];

    if (count > 0) {
        [self.tableView.backgroundView setHidden:YES];
    } else {
        [self.tableView.backgroundView setHidden:NO];
    }

    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FBLChatCell *cell = [tableView dequeueReusableCellWithIdentifier:kChatCellIdentifier forIndexPath:indexPath];
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
    [self startChat:message[PF_CHAT_GROUPID]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - listeners

- (void)setupListeners {
    [self listenForCreateSingleChatNotification];
    [self listenForAnyoneChatNotification];
}

- (void)listenForCreateSingleChatNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(createSingleChat)
                   name:kCreateSingleChat
                 object:nil];
}

- (void)listenForAnyoneChatNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(createAnyoneChat)
                   name:kChatToAnyone
                 object:nil];
}

#pragma mark - Socket Rocket

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSData *objectData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    NSString *eventType = [json objectForKey:@"type"];

    if ([eventType isEqualToString:@"hello"]) {
        NSLog(@"WEBSOCKET PING RECEIVED");
    } else {

    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"WEBSOCKET initialization - setup collections");

}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"WEBSCOKET FAILED *** %@", error.localizedDescription);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
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
