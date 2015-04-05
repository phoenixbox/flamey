//
//  FLSelectionCollectionEmptyMessageView.h
//  Flamey
//
//  Created by Shane Rogers on 3/7/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kGetFacebookPhotos;

@interface FLSelectionCollectionEmptyMessageView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@property (weak, nonatomic) IBOutlet UIButton *getFacebookPhotosButton;
- (IBAction)getFacebookPhotos:(id)sender;
@end
