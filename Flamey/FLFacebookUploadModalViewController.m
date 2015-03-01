//
//  FBSaveModalViewController.m
//  Flamey
//
//  Created by Shane Rogers on 2/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookUploadModalViewController.h"

// Libs
#import <MBProgressHUD/MBProgressHUD.h>

// Data Layer
#import "FLProcessedImagesStore.h"

@interface FLFacebookUploadModalViewController ()

@property (nonatomic, strong) MBProgressHUD *hud;

@end

@implementation FLFacebookUploadModalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [_readyButton setUserInteractionEnabled:NO];
    [_readyButton setBackgroundColor:[UIColor redColor]];

    [self uploadPhotos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// TODO: Be aware of iOS version upload restrictions
- (void)uploadPhotos {

    FLProcessedImagesStore *processedImageStore = [FLProcessedImagesStore sharedStore];
    FLPhoto *processedPhoto = processedImageStore.photos.lastObject;
    UIImage *img = processedPhoto.image;

    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setCenter:self.view.center];
    _hud.mode = MBProgressHUDModeAnnularDeterminate;
    _hud.labelText = @"Loading";

    [self performPublishAction:^{
        FBRequestConnection *connection = [[FBRequestConnection alloc] init];
        connection.errorBehavior = FBRequestConnectionErrorBehaviorReconnectSession
        | FBRequestConnectionErrorBehaviorAlertUser
        | FBRequestConnectionErrorBehaviorRetry;

        [_hud show:YES];

        [connection addRequest:[FBRequest requestForUploadPhoto:img]

             completionHandler:^(FBRequestConnection *innerConnection, id result, NSError *error) {
                 [_hud hide:YES];
                 if (!error) {
                       [_readyButton setTitle:@"Finished" forState:UIControlStateNormal];
                       [_readyButton setUserInteractionEnabled:YES];
                       [_readyButton setBackgroundColor:[UIColor greenColor]];
                   } else {
                       NSLog(@"Error %@", error.localizedDescription);
                   }             }];

        [connection start];
    }];
}

- (void)requestConnection:(FBRequestConnection *)connection
          didSendBodyData:(NSInteger)bytesWritten
        totalBytesWritten:(NSInteger)totalBytesWritten
totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    float progress = totalBytesWritten/totalBytesExpectedToWrite;
    NSLog(@"Progress Total: %f", progress);
    _hud.progress = progress;
}


- (void)performPublishAction:(void(^)(void))action {
    // we defer request for permission to post to the moment of post, then we check for the permission
    if ([FBSession.activeSession.permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        // if we don't already have the permission, then we request it now
        [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                              defaultAudience:FBSessionDefaultAudienceOnlyMe
                                            completionHandler:^(FBSession *session, NSError *error) {
                                                if (!error) {
                                                    action();
                                                } else if (error.fberrorCategory != FBErrorCategoryUserCancelled) {
                                                    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Permission denied"
                                                                                                        message:@"Unable to get permission to post"
                                                                                                       delegate:nil
                                                                                              cancelButtonTitle:@"OK"
                                                                                              otherButtonTitles:nil];
                                                    [alertView show];
                                                }
                                            }];
    } else {
        action();
    }

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
