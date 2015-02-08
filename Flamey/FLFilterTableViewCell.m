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
    [FLViewHelpers formatLabel:_filterLabel withCopy:copy andFontFamily:nil];
    [self rotateElement:_filterLabel];
}

- (void)setCellImage:(UIImage *)image {
    [_filterImageView setImage:image];

    [self rotateElement:_filterImageView];
}

- (void)setOverlayImage:(NSString *)labelName {
    [_overlayLabel setAttributedText:[FLViewHelpers attributeText:labelName forFontSize:25.0f andFontFamily:@"Avenir-Medium"]];
    [FLViewHelpers sizeLabelToFit:_overlayLabel numberOfLines:1];
    [self rotateElement:_overlayLabel];
    [_overlayLabel setTextColor:[UIColor whiteColor]];
}

@end
