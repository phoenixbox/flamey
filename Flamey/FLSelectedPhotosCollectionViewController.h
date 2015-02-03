//
//  FLSelectedPhotosCollectionViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RTFacebookAlbumViewController.h"

@interface FLSelectedPhotosCollectionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate, RTFacebookViewDelegate>

- (IBAction)showAlbums:(id)sender;

@end

