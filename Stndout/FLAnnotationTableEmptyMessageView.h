//
//  FLAnnotationTableEmptyMessageView.h
//  Flamey
//
//  Created by Shane Rogers on 3/7/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *const kAddMorePhotos;
extern NSString *const kRefreshCollection;

@interface FLAnnotationTableEmptyMessageView : UIView
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *refreshCollectionButton;
@property (weak, nonatomic) IBOutlet UILabel *emptyMessage;
@property (weak, nonatomic) IBOutlet UIButton *addPhotosButton;
- (IBAction)addPhotos:(id)sender;
- (IBAction)refreshCollection:(id)sender;

@end
