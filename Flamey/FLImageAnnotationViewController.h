//
//  FLImageAnnotationViewController.h
//  Flamey
//
//  Created by Shane Rogers on 2/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLPhoto.h"
#import "MDCSwipeToChooseDelegate.h"

@interface FLImageAnnotationViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, MDCSwipeToChooseDelegate>

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *addFiltersButton;
@property (weak, nonatomic) IBOutlet UIView *tableContainer;
@property (assign, nonatomic) NSInteger targetRow;

@property (weak, nonatomic) IBOutlet UIButton *removeSelectedPhoto;
@property (weak, nonatomic) IBOutlet UIButton *keepAnnotatedPhoto;
- (IBAction)removePhotoAction:(id)sender;
- (IBAction)keepPhoto:(id)sender;
@property (strong, nonatomic) FLPhoto *selectedPhoto;
@end
