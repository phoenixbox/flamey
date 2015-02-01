//
//  FLFilterTableViewCell.m
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFilterTableViewCell.h"

// Constants
#import "FLViewHelpers.h"
#import "FLStyleConstants.h"

@implementation FLFilterTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)renderSelectionIndicator {
    self.selectionIndicator = [[UIView alloc] initWithFrame:CGRectMake(5.0,10.0,2.0f,50.0)];
    [self.selectionIndicator setBackgroundColor:[UIColor blackColor]];

    [self addSubview:self.selectionIndicator];
}

- (void)rotateElement:(UIView *)element {
    CGAffineTransform rotate = CGAffineTransformMakeRotation(M_PI_2);
    [element setTransform:rotate];
}

- (void)setCellLabel:(NSString *)copy {
    [TAGViewHelpers formatLabel:_filterLabel withCopy:copy andFontFamily:nil];
    [self rotateElement:_filterLabel];
    [TAGViewHelpers sizeLabelToFit:_filterLabel numberOfLines:1];
}

- (void)setCellImage:(UIImage *)image {
    UIGraphicsBeginImageContextWithOptions(self.filterImageContainer.frame.size, NO, image.scale);
    [image drawInRect:self.filterImageContainer.bounds];
    UIImage* redrawn = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.filterImageContainer setBackgroundColor:[UIColor colorWithPatternImage:redrawn]];
    [self rotateElement:self.filterImageContainer];
}

- (void)setOverlayImage:(NSString *)labelName {
    UILabel *overlayLabel = [UILabel new];
    [overlayLabel setAttributedText:[TAGViewHelpers attributeText:labelName forFontSize:25.0f andFontFamily:@"WalkwaySemiBold"]];
    [TAGViewHelpers sizeLabelToFit:overlayLabel numberOfLines:1];
    [self rotateElement:overlayLabel];
    [overlayLabel setCenter:self.filterImageContainer.center];
    [overlayLabel setTextColor:[UIColor whiteColor]];
    [self.contentView addSubview:overlayLabel];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
