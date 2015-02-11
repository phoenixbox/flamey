//
//  FLImageAnnotationViewController.h
//  Flamey
//
//  Created by Shane Rogers on 2/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLPhoto.h"

@interface FLImageAnnotationViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *addFiltersButton;

@property (strong, nonatomic) FLPhoto *selectedPhoto;
@end
