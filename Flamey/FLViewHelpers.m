//
//  FLViewHelpers.m
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLViewHelpers.h"

@implementation FLViewHelpers

+ (NSMutableAttributedString *)createIcon:(FAKFontAwesome *)icon withColor:(UIColor *)color {
    NSAttributedString *heartFont = [icon attributedString];
    NSMutableAttributedString *heartIcon = [heartFont mutableCopy];
    [heartIcon addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0,heartIcon.length)];

    return heartIcon;
}

@end
