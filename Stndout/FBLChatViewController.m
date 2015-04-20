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

// Libs
#import <Parse/Parse.h>
#import "MBProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>

// Utils
#import "FBLViewhelpers.h"
#import "FBLCameraUtil.h"
#import "FBLMessageController.h"
#import "FBLPushNotificationController.h"

@interface FBLChatViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) NSString *channelId;

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

- (id)initWithSlackChannel:(NSString *)channelId {
    self = [super init];
    self.channelId = channelId;

    self.channel = [[FBLChannelStore sharedStore] find:channelId];

    // TODO: A better error pattern would be to try to reconnect the user to an active room
    if (!self.channel) {
        SIAlertView *alert = [FBLViewHelpers createAlertForError:nil
                                                       withTitle:@"Ooops!" andMessage:@"We had trouble connecting to that channel"];
        [alert show];
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupHUD];

    self.title = [NSString stringWithFormat:@"The %@ Channel", self.channelId];

    _users = [[NSMutableArray alloc] init];
    _messages = [[NSMutableArray alloc] init];
    _chatCollection = [[FBLChatCollection alloc] init];
    _avatars = [[NSMutableDictionary alloc] init];

    self.senderId = [[PFUser currentUser] objectForKey:@"facebookId"];
    self.senderDisplayName = [[PFUser currentUser] objectForKey:@"fullname"];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    _bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    _bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

    _avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:BLANK_AVATAR_IMG] diameter:30.0];

    _isLoading = NO;
    _initialized = NO;

    // Need some sort of promise like chaining of completion blocks
    void(^completionBlock)(NSError *err)=^(NSError *error) {
        [self loadSlackMessages];
    };

    void(^refreshWebhook)(NSError *err)=^(NSError *error) {
        if (error == nil) {
            [self setupWebsocket];
            [[FBLMembersStore sharedStore] fetchMembersWithCompletion:completionBlock];
        }
    };

    [[FBLSlackStore sharedStore] setupWebhook:refreshWebhook];
//    [self loadParseMessages];
}

- (void)setupWebsocket {
    NSString *websocketUrl = [FBLSlackStore sharedStore].webhookUrl;

    SRWebSocket *newWebSocket = [[SRWebSocket alloc] initWithURL:[NSURL URLWithString:websocketUrl]];
    newWebSocket.delegate = self;

    [newWebSocket open];
}

- (void)setupHUD {
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setCenter:self.view.center];
    _hud.mode = MBProgressHUDModeIndeterminate;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;

//    TODO: Setup the incoming webhook for slack to receive messages from the channel
//    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadSlackMessages) userInfo:nil repeats:YES];

//    Parse Polling for Messages
//    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadParseMessages) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    ClearMessageCounter(_channelId);
    [_timer invalidate];
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
                SIAlertView *alert = [FBLViewHelpers createAlertForError:nil
                                                               withTitle:@"Ooops!" andMessage:error];
                [alert show];
            }

            [self.collectionView reloadData];
            _isLoading = NO;
        };

        [[FBLChatStore sharedStore] fetchHistoryForChannel:_channelId withCompletion:completionBlock];
    }
}

//- (void)loadParseMessages {
//    if (_isLoading == NO)
//    {
//        _isLoading = YES;
//        JSQMessage *message_last = [_messages lastObject];
//
//        PFQuery *query = [PFQuery queryWithClassName:PF_MESSAGE_CLASS_NAME];
//        [query whereKey:PF_MESSAGE_GROUPID equalTo:_channelId];
//
//        if (message_last != nil) {
//            [query whereKey:PF_MESSAGE_CREATEDAT greaterThan:message_last.date];
//        }
//
//        [query includeKey:PF_MESSAGE_USER];
//        [query orderByDescending:PF_MESSAGE_CREATEDAT];
//        [query setLimit:50];
//        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
//             if (error == nil) {
//                 BOOL incoming = NO;
//                 self.automaticallyScrollsToMostRecentMessage = NO;
//                 for (PFObject *object in [objects reverseObjectEnumerator])
//                 {
//                     JSQMessage *message = [self addParseMessage:object];
//                     if ([self incoming:message]) {
//                         incoming = YES;
//                     }
//                 }
//                 if ([objects count] != 0)
//                 {
//                     if (_initialized && incoming)
//                         [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
//                     [self finishReceivingMessage];
//                     [self scrollToBottomAnimated:NO];
//                 }
//                 self.automaticallyScrollsToMostRecentMessage = YES;
//                 _initialized = YES;
//                 [_hud hide:YES];
//             }
//             else {
//                 SIAlertView *alert = [FBLViewHelpers createAlertForError:error
//                                           withTitle:@"Ooops!" andMessage:@"We had trouble loading messages"];
//                 [alert show];
//             }
//
//             _isLoading = NO;
//         }];
//    }
//}

- (JSQMessage *)addSlackMessage:(FBLChat *)chat {
    JSQMessage *message;
    NSString *senderId;
    NSString *displayName;
    NSString *username = chat.username;

    if ([username isEqualToString:@"bot"]) {

        // A user is added for every message - paired collection
        PFUser *user = [PFUser currentUser];
        [_users addObject:user];

        senderId = [[PFUser currentUser] objectForKey:@"facebookId"];
        displayName = [[PFUser currentUser] objectForKey:@"fullname"];
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

//- (JSQMessage *)addParseMessage:(PFObject *)object {
//    JSQMessage *message;
//
//    PFUser *user = object[PF_MESSAGE_USER];
//    NSString *name = user[PF_CUSTOMER_FULLNAME];
//
//    PFFile *fileVideo = object[PF_MESSAGE_VIDEO];
//    PFFile *filePicture = object[PF_MESSAGE_PICTURE];
//
//    if ((filePicture == nil) && (fileVideo == nil))
//    {
//        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[PF_MESSAGE_TEXT]];
//    }
//
//    if (fileVideo != nil)
//    {
//        JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:fileVideo.url] isReadyToPlay:YES];
//        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
//        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
//    }
//
//    if (filePicture != nil)
//    {
//        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
//        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
//        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
//
//        [filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
//         {
//             if (error == nil)
//             {
//                 mediaItem.image = [UIImage imageWithData:imageData];
//                 [self.collectionView reloadData];
//             }
//         }];
//    }
//
//    [_users addObject:user];
//    [_messages addObject:message];
//
//    return message;
//}

- (void)sendMessageToSlack:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture {

    void(^completionBlock)(FBLChat *chat, NSString *error)=^(FBLChat *chat, NSString *error) {
        if (error == nil)
        {
            [JSQSystemSoundPlayer jsq_playMessageSentSound];

            // Reload not necessary - optimize load feel
            [self loadSlackMessages];
        }
        else {
            // TODO: Add a retry send message helper - and flag the error in the UI
            SIAlertView *alert = [FBLViewHelpers createAlertForError:nil
                                                           withTitle:@"Ooops!" andMessage:error];
            [alert show];
        };
    };

    [[FBLChatStore sharedStore] sendSlackMessage:text toChannel:self.channel withCompletion:completionBlock];

//    SendPushNotification(_channelId, text);
//    UpdateMessageCounter(_channelId, text);

    [self finishSendingMessage];
}

//- (void)sendMessageToParse:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture {
//    PFFile *fileVideo = nil;
//    PFFile *filePicture = nil;
//
//    if (video != nil)
//    {
//        text = @"[Video message]";
//        fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
//        [fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//         {
//             if (error != nil) {
//                 SIAlertView *alert = [FBLViewHelpers createAlertForError:error
//                                                                withTitle:@"Ooops!" andMessage:@"We had trouble saving that video"];
//                 [alert show];
//             }
//         }];
//    }
//
//    if (picture != nil)
//    {
//        text = @"[Picture message]";
//        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
//        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//         {
//             if (error != nil) {
//                 SIAlertView *alert = [FBLViewHelpers createAlertForError:error
//                                                                withTitle:@"Ooops!" andMessage:@"We had trouble saving picture"];
//                 [alert show];
//             }
//         }];
//    }
//
//    PFObject *object = [PFObject objectWithClassName:PF_MESSAGE_CLASS_NAME];
//    object[PF_MESSAGE_USER] = [PFUser currentUser];
//    object[PF_MESSAGE_GROUPID] = _channelId;
//    object[PF_MESSAGE_TEXT] = text;
//    if (fileVideo != nil) object[PF_MESSAGE_VIDEO] = fileVideo;
//    if (filePicture != nil) object[PF_MESSAGE_PICTURE] = filePicture;
//    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
//     {
//         if (error == nil)
//         {
//             [JSQSystemSoundPlayer jsq_playMessageSentSound];
//             [self loadParseMessages];
//         }
//         else {
//             SIAlertView *alert = [FBLViewHelpers createAlertForError:error
//                                                        withTitle:@"Ooops!" andMessage:@"We had trouble saving that message"];
//             [alert show];
//         };
//     }];
//
//    SendPushNotification(_channelId, text);
//    UpdateMessageCounter(_channelId, text);
//
//    [self finishSendingMessage];
//}

#pragma mark - JSQMessagesViewController protocol methods

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {

    // Send to Slack
    [self sendMessageToSlack:text Video:nil Picture:nil];
    // Send to Parse
//    [self sendMessageToParse:text Video:nil Picture:nil];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Share Photo", @"Share Video", nil];
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

- (id<JSQMessageAvatarImageDataSource>)getParseUserImage:(PFObject *)user {
    if (_avatars[user.objectId] == nil) {

        PFFile *file = user[PF_CUSTOMER_THUMBNAIL];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 _avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
                 [self.collectionView reloadData];
             }
         }];
        return _avatarImageBlank;
    } else {
        return _avatars[user.objectId];
    }
}


- (id<JSQMessageAvatarImageDataSource>)getFBLUserImage:(FBLMember *)member {
    if (_avatars[member.id] == nil) {
        PFQuery *query = [PFQuery queryWithClassName:PF_MEMBER_CLASS_NAME];
        [query whereKey:PF_MEMBER_SLACKID equalTo:member.id];
        NSArray *members = [query findObjects];

        if ([members count]>0) {
            PFFile *file = members[0][PF_CUSTOMER_THUMBNAIL];
            [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
             {
                 if (error == nil)
                 {
                     _avatars[member.id] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
                     [self.collectionView reloadData];
                 }
             }];
            return _avatarImageBlank;
        } else {
            return _avatarImageBlank;
        }
    } else {
        return _avatars[member.id];
    }
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Meta FTW
    id newObject = _users[indexPath.item];
    NSString *className = NSStringFromClass([newObject class]);

    if ([className isEqualToString:@"PFUser"]) {
        PFObject *user = (PFObject *)newObject;
        return [self getParseUserImage:user];
    } else {
        FBLMember *user = (FBLMember *)newObject;
        return [self getFBLUserImage:user];
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
        } else if (buttonIndex == 1) {
            ShouldStartVideoLibrary(self, YES);
        } else {
            NSLog(@"Error: No Action for Button Index");
        }
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    NSURL *video = info[UIImagePickerControllerMediaURL];
    UIImage *picture = info[UIImagePickerControllerEditedImage];

    // TODO: Implement image picker transfer
//    [self sendMessageToParse:nil Video:video Picture:picture];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

- (BOOL)isIncomingChat:(FBLChat *)chat {
    return ![chat.username isEqualToString:@"bot"];
}

- (BOOL)isOutgoingChat:(FBLChat *)chat {
    return ![chat respondsToSelector:@selector(username)]; // Janky
//     [chat.username isEqualToString:@"bot"];
}

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
        NSLog(@"WEBSOCKET PING RECEIVED");
    } else if ([eventType isEqualToString:@"message"]) {
        NSString *channelId = [json objectForKey:@"channel"];;

        if ([channelId isEqualToString:self.channelId]) {
            FBLChat *newMessage = [[FBLChat alloc] initWithDictionary:json error:nil];
            [self addSlackMessage:newMessage];

            [self.collectionView reloadData];
            [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
            [self finishReceivingMessage];
//            [self scrollToBottomAnimated:NO];
        }
    }
}

- (void)webSocketDidOpen:(SRWebSocket *)webSocket {
    NSLog(@"WEBSOCKET OPENED ");
}

- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error {
    NSLog(@"WEBSCOKET FAILED *** %@", error.localizedDescription);
}

- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean {
}

@end
