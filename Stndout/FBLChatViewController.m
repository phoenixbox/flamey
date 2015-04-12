//
//  ChatViewController.m
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLChatViewController.h"
#import <MediaPlayer/MediaPlayer.h>

#import <Parse/Parse.h>
// Constants
#import "FBLAppConstants.h"

#import "MBProgressHUD.h"
//#import "ProgressHUD.h"

//#import "camera.h"
#import "FBLMessageController.h"
#import "FBLPushNotificationController.h"

@interface FBLChatViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) NSString *channelId;

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *avatars;

@property (nonatomic, strong) MBProgressHUD *hud;

@property (nonatomic, strong) JSQMessagesBubbleImage *bubbleImageOutgoing;
@property (nonatomic, strong) JSQMessagesBubbleImage *bubbleImageIncoming;
@property (nonatomic, strong) JSQMessagesAvatarImage *avatarImageBlank;

@end

@implementation FBLChatViewController

- (id)initWithSlackChannel:(NSString *)channelId {
    self = [super init];
    self.channelId = channelId;

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupHUD];

    self.title = [NSString stringWithFormat:@"Chat with, %@", @"Blair" ];

    _users = [[NSMutableArray alloc] init];
    _messages = [[NSMutableArray alloc] init];
    _avatars = [[NSMutableDictionary alloc] init];

    // TODO: Set real user information here
    PFUser *user = [PFUser currentUser];

    self.senderId = PF_STUB_USER_ID;

    self.senderDisplayName = user[PF_USER_FULLNAME];

    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    _bubbleImageOutgoing = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    _bubbleImageIncoming = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];

    _avatarImageBlank = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageNamed:@"persona"] diameter:30.0];

    _isLoading = NO;
    _initialized = NO;
    [self loadMessages];
}

- (void)setupHUD {
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setCenter:self.view.center];
    _hud.mode = MBProgressHUDModeIndeterminate;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    ClearMessageCounter(_channelId);
    [_timer invalidate];
}

#pragma mark - Backend methods

- (void)loadMessages {
    if (_isLoading == NO)
    {
        _isLoading = YES;
        JSQMessage *message_last = [_messages lastObject];

        PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [query whereKey:PF_CHAT_GROUPID equalTo:_channelId];
        if (message_last != nil) [query whereKey:PF_CHAT_CREATEDAT greaterThan:message_last.date];
        [query includeKey:PF_CHAT_USER];
        [query orderByDescending:PF_CHAT_CREATEDAT];
        [query setLimit:50];
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error)
         {
             if (error == nil)
             {
                 BOOL incoming = NO;
                 self.automaticallyScrollsToMostRecentMessage = NO;
                 for (PFObject *object in [objects reverseObjectEnumerator])
                 {
                     JSQMessage *message = [self addMessage:object];
                     if ([self incoming:message]) incoming = YES;
                 }
                 if ([objects count] != 0)
                 {
                     if (_initialized && incoming)
                         [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                     [self finishReceivingMessage];
                     [self scrollToBottomAnimated:NO];
                 }
                 self.automaticallyScrollsToMostRecentMessage = YES;
                 _initialized = YES;
             }
             else {

                 _hud.labelText = @"Loading";
                 [_hud show:YES];
             }

             _isLoading = NO;
         }];
    }
}

- (JSQMessage *)addMessage:(PFObject *)object {
    JSQMessage *message;

    PFUser *user = object[PF_CHAT_USER];
    NSString *name = user[PF_USER_FULLNAME];

    PFFile *fileVideo = object[PF_CHAT_VIDEO];
    PFFile *filePicture = object[PF_CHAT_PICTURE];

    if ((filePicture == nil) && (fileVideo == nil))
    {
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt text:object[PF_CHAT_TEXT]];
    }

    if (fileVideo != nil)
    {
        JSQVideoMediaItem *mediaItem = [[JSQVideoMediaItem alloc] initWithFileURL:[NSURL URLWithString:fileVideo.url] isReadyToPlay:YES];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];
    }

    if (filePicture != nil)
    {
        JSQPhotoMediaItem *mediaItem = [[JSQPhotoMediaItem alloc] initWithImage:nil];
        mediaItem.appliesMediaViewMaskAsOutgoing = [user.objectId isEqualToString:self.senderId];
        message = [[JSQMessage alloc] initWithSenderId:user.objectId senderDisplayName:name date:object.createdAt media:mediaItem];

        [filePicture getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 mediaItem.image = [UIImage imageWithData:imageData];
                 [self.collectionView reloadData];
             }
         }];
    }

    [_users addObject:user];
    [_messages addObject:message];

    return message;
}

- (void)sendMessage:(NSString *)text Video:(NSURL *)video Picture:(UIImage *)picture {
    PFFile *fileVideo = nil;
    PFFile *filePicture = nil;

    if (video != nil)
    {
        text = @"[Video message]";
        fileVideo = [PFFile fileWithName:@"video.mp4" data:[[NSFileManager defaultManager] contentsAtPath:video.path]];
        [fileVideo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) {
                 NSLog(@"Video save error: %@", error.localizedDescription);
             }
         }];
    }

    if (picture != nil)
    {
        text = @"[Picture message]";
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) {
                NSLog(@"Picture save error: %@", error.localizedDescription);
             }
         }];
    }

    PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    object[PF_CHAT_USER] = [PFUser currentUser];
    object[PF_CHAT_GROUPID] = _channelId;
    object[PF_CHAT_TEXT] = text;
    if (fileVideo != nil) object[PF_CHAT_VIDEO] = fileVideo;
    if (filePicture != nil) object[PF_CHAT_PICTURE] = filePicture;
    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
     {
         if (error == nil)
         {
             [JSQSystemSoundPlayer jsq_playMessageSentSound];
             [self loadMessages];
         }
         else {
             NSLog(@"Sending Message Error: %@", error.localizedDescription);
         };
     }];

    SendPushNotification(_channelId, text);
    UpdateMessageCounter(_channelId, text);

    [self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    [self sendMessage:text Video:nil Picture:nil];
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

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = _users[indexPath.item];

    if (_avatars[user.objectId] == nil)
    {
        PFFile *file = user[PF_USER_THUMBNAIL];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 _avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
                 [self.collectionView reloadData];
             }
         }];
        return _avatarImageBlank;
    }
    else {
        return _avatars[user.objectId];
    }
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = _messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    else return nil;
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

    [self sendMessage:nil Video:video Picture:picture];

    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Helper methods

- (BOOL)incoming:(JSQMessage *)message {
    return ([message.senderId isEqualToString:self.senderId] == NO);
}

- (BOOL)outgoing:(JSQMessage *)message {
    return ([message.senderId isEqualToString:self.senderId] == YES);
}


@end
