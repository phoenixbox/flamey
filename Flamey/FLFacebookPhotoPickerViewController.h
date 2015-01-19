//
//  FLFacebookPhotoCollectionViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/17/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLFacebookPhotoPickerViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource>

@property (strong) NSString* albumId;

@end
