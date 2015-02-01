//
//  FLLateralTableViewCell.h
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLLateralTableViewCell : UITableViewCell

@property (nonatomic, assign) float cellDimension;
@property (nonatomic, strong) UIImage *artImage;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier forCellDimension:(float)dimension;

@end