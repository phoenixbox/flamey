//
//  ChatViewController.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChatViewController.h"
#import <MediaPlayer/MediaPlayer.h>

// Constants
#import "FBLAppConstants.h"

// Data Layer
#import "FBLChannel.h"
#import "FBLChannelStore.h"
#import "FBLChat.h"
#import "FBLChatCollection.h"
#import "FBLChatStore.h"
#import "FBLMembersStore.h"
#import "FBLSlackStore.h"
#import "FBLAuthenticationStore.h"

// Libs
#import "MBProgressHUD.h"

// Utils
#import "FBLCameraUtil.h"

@interface FBLChatViewController ()

@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) NSString *userChannelId;
@property (nonatomic, strong) UIView *emptyMessage;

@property (nonatomic, strong) UIView *navBar;

@property (nonatomic, strong) FBLChannel *channel;

@property (nonatomic, strong) FBLChatCollection *chatCollection;

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *avatars;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) JSQMessagesBubbleImage *bubbleImageOutgoing;
@property (nonatomic, strong) JSQMessagesBubbleImage *bubbleImageIncoming;
@property (nonatomic, strong) JSQMessagesAvatarImage *avatarImageBlank;

@property (nonatomic, strong) SRWebSocket *webSocket;

@end

@implementation FBLChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNavigationBar];
    [self setupHUD];
    [self initializeCollectionErrorView];

    self.title = [NSString stringWithFormat:@"FeedbackLoop Chat"];

    _users = [[NSMutableArray alloc] init];
    _messages = [[NSMutableArray alloc] init];
    _chatCollection = [[FBLChatCollection alloc] init];
    _avatars = [[NSMutableDictionary alloc] init];

    // NOTE: We need to satisfy the JSQMessages internal prop requirements
    self.senderId = [[FBLAuthenticationStore sharedInstance] AppId];
    self.senderDisplayName = [[FBLAuthenticationStore sharedInstance] userEmail];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    _bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    _bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

    _avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:BLANK_AVATAR_IMG] diameter:30.0];

    _isLoading = NO;
    _initialized = NO;

    [self slackOauth];
}

- (void)addNavigationBar {
    UIView *navBar = [[UIView alloc] initWithFrame:CGRectMake(0,0,self.view.bounds.size.width,50)];
    [navBar setBackgroundColor:[UIColor whiteColor]];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    [logoView setCenter:navBar.center];
    [navBar addSubview:logoView];

    UIImage *removeIcon = [UIImage imageNamed:@"removeIcon.png"];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(5.0,5.0,40.0,40.0)];
    [button setBackgroundImage:removeIcon forState:UIControlStateNormal];
    [button addTarget:self action:@selector(hideFeedbackLoopWindow) forControlEvents:UIControlEventTouchUpInside];
    [navBar addSubview:button];

    [self.view addSubview:navBar];
}

- (void)initializeCollectionErrorView {
    CGRect collectionViewBounds = [self.collectionView bounds];
    _emptyMessage = [[UIView alloc] initWithFrame:collectionViewBounds];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0,0,collectionViewBounds.size.width-20.0f, 50.0f)];
    [label setText:@"Uh Oh! We had trouble connecting"];
    [label setTextAlignment:NSTextAlignmentCenter];
    [label setCenter:_emptyMessage.center];
    [_emptyMessage addSubview:label];

    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(collectionViewBounds.size.width/4,
                                                                  label.frame.origin.y + label.frame.size.height + 10.0f,
                                                                  collectionViewBounds.size.width/2,
                                                                  40.0f)];
    [button addTarget:self
                 action:@selector(slackOauth)
       forControlEvents:UIControlEventTouchUpInside];

    [self styleButton:button withColor:[UIColor blackColor]];

    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];

    [_emptyMessage addSubview:button];
    [self.collectionView setBackgroundView:_emptyMessage];
    [self hideErrorView:YES];
}

- (void)styleButton:(UIButton *)button withColor:(UIColor *)color {
    button.layer.cornerRadius = 4;
    button.layer.borderWidth = 2;
    button.layer.borderColor = color.CGColor;
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTintColor:color];

}

- (void)hideErrorView:(BOOL)show {
    if (show) {
        [self.collectionView.backgroundView setHidden:YES];
    } else {
        [self.collectionView.backgroundView setHidden:NO];
    }
}

- (void)slackOauth {
    [_hud show:YES];
    [self hideErrorView:YES];

    void(^refreshWebhook)(NSError *err)=^(NSError *error) {
        [_hud hide:YES];

        if (error == nil) {
            [self setChannelDetails];
            [self setupWebsocket];
            [self loadSlackMessages];
        } else {
            [self hideErrorView:NO];
        }
    };

    [[FBLSlackStore sharedStore] slackOAuth:refreshWebhook];
}

- (void)hideFeedbackLoopWindow {
    [self flushWebSocket];
    _popWindow();
}

- (void)flushWebSocket {
    [_webSocket close];
    [FBLSlackStore sharedStore].webhookUrl = nil;
    _webSocket.delegate = nil;
    _webSocket = nil;
}

- (void)setChannelDetails {
    self.userChannelId = [[FBLSlackStore sharedStore] userChannelId];
    self.channel = [[FBLChannelStore sharedStore] find:self.userChannelId];
}

- (void)setupWebsocket {
    NSString *websocketUrl = [FBLSlackStore sharedStore].webhookUrl;

    _webSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:websocketUrl]];
    _webSocket.delegate = self;

    [_webSocket open];
}

- (void)setupHUD {
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setCenter:self.view.center];
    _hud.mode = MBProgressHUDModeIndeterminate;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Backend methods

- (void)loadSlackMessages {
    if (_isLoading == NO) {
        _isLoading = YES;

        void(^completionBlock)(FBLChatCollection *chatCollection, NSString *error)=^(FBLChatCollection *chatCollection, NSString *error) {

            if (error == nil) {

                BOOL incoming = NO;

                self.automaticallyScrollsToMostRecentMessage = NO;

                for (FBLChat *chat in [chatCollection.messages reverseObjectEnumerator])
                {
                    [self addSlackMessage:chat];

                    if (![chat.username isEqualToString:@"bot"]) {
                        incoming = YES;
                    }
                }

                if ([_messages count] != 0)
                {
                    if (_initialized && incoming) {
                        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                    }

                    [self finishReceivingMessage];
                    [self scrollToBottomAnimated:NO];
                }
                self.automaticallyScrollsToMostRecentMessage = YES;
                _initialized = YES;
                [_hud hide:YES];
            }
            else {
                // Todo replace background view with the correct title
            }

            [self.collectionView reloadData];
            _isLoading = NO;
        };

        [[FBLChatStore sharedStore] fetchHistoryForChannel:_userChannelId withCompletion:completionBlock];
    }
}

- (JSQMessage *)addSlackMessage:(FBLChat *)chat {
    JSQMessage *message;
    NSString *senderId;
    NSString *displayName;
    NSString *username = chat.username;

    if ([username isEqualToString:@"bot"]) {

        // Add a user which can be pulled on an
        FBLMember *member = [[FBLMember alloc] init];
        [member setId:self.senderId];
        [member setEmail:self.senderDisplayName];
        [member setProfileImage:nil];

        [_users addObject:member];

        senderId = self.senderId;
        displayName = self.senderDisplayName;
    } else {
        senderId = chat.user;
        FBLMember *member = [[FBLMembersStore sharedStore] find:chat.user];
        // Should the member attributes be transferred to an object with the same scheme as the PFUser?
        [_users addObject:member];

        displayName = member.realName;
    }

    NSDate *dateStamp = [NSDate dateWithTimeIntervalSince1970:
                         [chat.ts doubleValue]];

    message = [[JSQMessage alloc] initWithSenderId:senderId senderDisplayName:displayName date:dateStamp text:chat.text];

    [_messages addObject:message];

    return message;
}

- (void)sendMessageToSlack:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture {

    void(^completionBlock)(FBLChat *chat, NSString *error)=^(FBLChat *chat, NSString *error) {
        if (error == nil)
        {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];
        }
        else {
            // Update the background view message
            // Add the retry sending message helper to message button

        };
    };

    [[FBLChatStore sharedStore] sendSlackMessage:text toChannel:self.channel withCompletion:completionBlock];

    [self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController protocol methods

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {

    // Send to Slack
    [self sendMessageToSlack:text Video:nil Picture:nil];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil
                                                        delegate:self
                                               cancelButtonTitle:@"Cancel"
                                          destructiveButtonTitle:nil
                                               otherButtonTitles:@"Share Photo", nil];
    [action showInView:self.view];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return _messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {

    if ([self outgoing:_messages[indexPath.item]])
    {
        return _bubbleImageOutgoing;
    }
    else
    {
        return _bubbleImageIncoming;
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {

    FBLMember *member = _users[indexPath.item];

    if (_avatars[member.id] == nil) {
        if (member.profileImage) {
            JSQMessagesAvatarImage *avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:member.profileImage diameter:30.0];
            _avatars[member.id] = avatar;
            return avatar;
        } else {
            return _avatarImageBlank;
        }
    } else {
        return _avatars[member.id];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = _messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    } else {
        return nil;
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = _messages[indexPath.item];

    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = _messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return nil;
            }
        }
        return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
    }
    else return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [_messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    if ([self outgoing:_messages[indexPath.item]])
    {
        cell.textView.textColor = [UIColor blackColor];
    }
    else
    {
        cell.textView.textColor = [UIColor whiteColor];
    }
    return cell;
}

#pragma mark - JSQMessages collection view flow layout delegate

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 3 == 0)
    {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = _messages[indexPath.item];
    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = _messages[indexPath.item-1];
            if ([previous.senderId isEqualToString:message.senderId])
            {
                return 0;
            }
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    else return 0;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender {
    NSLog(@"didTapLoadEarlierMessagesButton");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView
           atIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"didTapAvatarImageView");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = _messages[indexPath.item];
    if (message.isMediaMessage)
    {
        if ([message.media isKindOfClass:[JSQVideoMediaItem class]])
        {
            JSQVideoMediaItem *mediaItem = (JSQVideoMediaItem *)message.media;
            MPMoviePlayerViewController *moviePlayer = [[MPMoviePlayerViewController alloc] initWithContentURL:mediaItem.fileURL];
            [self presentMoviePlayerViewControllerAnimated:moviePlayer];
            [moviePlayer.moviePlayer play];
        }
    }
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation {
    NSLog(@"didTapCellAtIndexPath %@", NSStringFromCGPoint(touchLocation));
}

#pragma mark - UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex)
    {
        if (buttonIndex == 0) {
            ShouldStartPhotoLibrary(self, YES);
        } else {
            NSLog(@"Error: No Action for Button Index");
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
//    NSURL *video = info[UIImagePickerControllerMediaURL];
//    UIImage *picture = info[UIImagePickerControllerEditedImage];

    // TODO: Implement image picker transfer

    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

- (BOOL)incoming:(JSQMessage *)message {

    return ([message.senderId isEqualToString:self.senderId] == NO);
}

- (BOOL)outgoing:(JSQMessage *)message {
    return ([message.senderId isEqualToString:self.senderId] == YES);
}

#pragma mark - Socket Rocket

- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message {
    NSData *objectData = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData
                                                         options:NSJSONReadingMutableContainers
                                                           error:nil];
    NSString *eventType = [json objectForKey:@"type"];

    if ([eventType isEqualToString:@"hello"]) {
        NSLog(@"WEBSOCKET RESPONSE RECEIVED");
    } else if ([eventType isEqualToString:@"message"]) {
        NSString *channelId = [json objectForKey:@"channel"];;

        if ([channelId isEqualToString:self.userChannelId]) {
            FBLChat *newMessage = [[FBLChat alloc] initWithDictionary:json error:nil];
            [self addSlackMessage:newMessage];

            [self.collectionView reloadData];
            [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
            [self finishReceivingMessage];
            [self scrollToBottomAnimated:NO];
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"WEBSOCKET OPENED");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"WEBSCOKET FAILED *** %@", error.localizedDescription);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
    NSLog(@"WEBSOCKET CLOSED");
}

@end
