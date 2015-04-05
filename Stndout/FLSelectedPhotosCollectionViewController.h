//
//  FLSelectedPhotosCollectionViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLSelectedPhotosCollectionViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *selectionCollection;
@property (weak, nonatomic) IBOutlet UIButton *editPhotosButton;
- (IBAction)editPhotos:(id)sender;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editCollectionButton;
- (IBAction)editCollection:(id)sender;


@end