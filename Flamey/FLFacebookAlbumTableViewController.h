//
//  FLFacebookAlbumTableViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/17/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "FLPhotosCollectionViewController.h"

@protocol FLPhotosCollectionViewController;

@interface FLFacebookAlbumTableViewController : UITableViewController <UIAlertViewDelegate>

+(void)showWithDelegate:(id<FLPhotosCollectionViewController>)delegate;

@end