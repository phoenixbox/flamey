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
//#import "ProgressHUD.h"

//#import "AppConstant.h"
//#import "camera.h"
//#import "messages.h"
//#import "pushnotification.h"

@interface FBLChatViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) BOOL isLoading;
@property (nonatomic, assign) BOOL initialized;

@property (nonatomic, strong) NSString *channelId;

@property (nonatomic, strong) NSMutableArray *users;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSMutableDictionary *avatars;

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


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.collectionView.collectionViewLayout.springinessEnabled = YES;
    _timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(loadMessages) userInfo:nil repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];

    ClearMessageCounter(_groupId);
    [_timer invalidate];
}

#pragma mark - Backend methods

- (void)loadMessages {
    if (_isLoading == NO)
    {
        isLoading = YES;
        JSQMessage *message_last = [messages lastObject];

        PFQuery *query = [PFQuery queryWithClassName:PF_CHAT_CLASS_NAME];
        [query whereKey:PF_CHAT_GROUPID equalTo:groupId];
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
                     if (initialized && incoming)
                         [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
                     [self finishReceivingMessage];
                     [self scrollToBottomAnimated:NO];
                 }
                 self.automaticallyScrollsToMostRecentMessage = YES;
                 initialized = YES;
             }
             else [ProgressHUD showError:@"Network error."];
             isLoading = NO;
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

    [users addObject:user];
    [messages addObject:message];

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
             if (error != nil) [ProgressHUD showError:@"Network error."];
         }];
    }

    if (picture != nil)
    {
        text = @"[Picture message]";
        filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
        [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
         {
             if (error != nil) [ProgressHUD showError:@"Picture save error."];
         }];
    }

    PFObject *object = [PFObject objectWithClassName:PF_CHAT_CLASS_NAME];
    object[PF_CHAT_USER] = [PFUser currentUser];
    object[PF_CHAT_GROUPID] = groupId;
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
         else [ProgressHUD showError:@"Network error."];;
     }];

    SendPushNotification(groupId, text);
    UpdateMessageCounter(groupId, text);

    [self finishSendingMessage];
}

#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button withMessageText:(NSString *)text senderId:(NSString *)senderId senderDisplayName:(NSString *)senderDisplayName date:(NSDate *)date {
    [self sendMessage:text Video:nil Picture:nil];
}

- (void)didPressAccessoryButton:(UIButton *)sender {
    UIActionSheet *action = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil
                                               otherButtonTitles:@"Take photo or video", @"Choose existing photo", @"Choose existing video", nil];
    [action showInView:self.view];
}

#pragma mark - JSQMessages CollectionView DataSource

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    return messages[indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
             messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self outgoing:messages[indexPath.item]])
    {
        return bubbleImageOutgoing;
    }
    else return bubbleImageIncoming;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView
                    avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath {
    PFUser *user = users[indexPath.item];
    if (avatars[user.objectId] == nil)
    {
        PFFile *file = user[PF_USER_THUMBNAIL];
        [file getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error)
         {
             if (error == nil)
             {
                 avatars[user.objectId] = [JSQMessagesAvatarImageFactory avatarImageWithImage:[UIImage imageWithData:imageData] diameter:30.0];
                 [self.collectionView reloadData];
             }
         }];
        return avatarImageBlank;
    }
    else return avatars[user.objectId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item % 3 == 0)
    {
        JSQMessage *message = messages[indexPath.item];
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    else return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = messages[indexPath.item-1];
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
    return [messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];

    if ([self outgoing:messages[indexPath.item]])
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
    JSQMessage *message = messages[indexPath.item];
    if ([self incoming:message])
    {
        if (indexPath.item > 0)
        {
            JSQMessage *previous = messages[indexPath.item-1];
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
    JSQMessage *message = messages[indexPath.item];
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
        if (buttonIndex == 0)	ShouldStartMultiCamera(self, YES);
        if (buttonIndex == 1)	ShouldStartPhotoLibrary(self, YES);
        if (buttonIndex == 2)	ShouldStartVideoLibrary(self, YES);
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
