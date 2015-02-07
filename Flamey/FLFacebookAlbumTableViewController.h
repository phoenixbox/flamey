//
//  FLFacebookAlbumTableViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/17/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#import "FLSelectedPhotosCollectionViewController.h"

@protocol FLPhotosCollectionViewController;

@interface FLFacebookAlbumTableViewController : UITableViewController <UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *albumTable;

+(void)showWithDelegate:(id<FLPhotosCollectionViewController>)delegate;

@end