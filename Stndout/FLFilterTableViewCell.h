//
//  FLFilterTableViewCell.h
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLFilterTableViewCell : UITableViewCell

- (void)setCellImage:(UIImage *)image;
- (void)setOverlayImage:(NSString *)labelName;
- (void)setCellLabel:(NSString *)copy;

@property (nonatomic, assign) float cellDimension;
@property (strong, nonatomic) UIImage *filteredImage;

@property (strong, nonatomic) IBOutlet UIImageView *filterImageView;
@property (weak, nonatomic) IBOutlet UILabel *overlayLabel;

@property (strong, nonatomic) IBOutlet UIView *selectionIndicator;
@property (strong, nonatomic) IBOutlet UILabel *filterLabel;

@end
