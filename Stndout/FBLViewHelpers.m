//
//  FBLViewHelpers.m
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLViewHelpers.h"

@implementation FBLViewHelpers

+ (void)setBaseButtonStyle:(UIButton *)button withColor:(UIColor *)color {
    // TODO Update for state variety
    button.layer.cornerRadius = 4;
    button.layer.borderWidth = 2;
    button.layer.borderColor = color.CGColor;
    [button setBackgroundColor:[UIColor whiteColor]];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button setTintColor:color];
}

@end
