//
//  FLAnnotationTableViewCell.h
//  Flamey
//
//  Created by Shane Rogers on 2/15/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLAnnotationTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *selectedImageViewBackground;
@property (strong, nonatomic) UIImage *facebookImage;

@end
