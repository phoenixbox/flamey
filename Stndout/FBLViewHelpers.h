//
//  FBLViewHelpers.h
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SIAlertView.h>

@interface FBLViewHelpers : NSObject

+ (void)setBaseButtonStyle:(UIButton *)button withColor:(UIColor *)color;

+ (SIAlertView *)createAlertForError:(NSError *)error
                           withTitle:(NSString *)title
                          andMessage:(NSString *)message;
@end
