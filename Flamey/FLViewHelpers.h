//
//  FLViewHelpers.h
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "FontAwesomeKit/FAKFontAwesome.h"

@interface FLViewHelpers : NSObject

+ (NSMutableAttributedString *)createIcon:(FAKFontAwesome *)icon withColor:(UIColor *)color;

+ (NSAttributedString *)attributeText:(NSString *)text forFontSize:(CGFloat)size andFontFamily:(NSString *)fontFamily;

+ (void)formatLabel:(UILabel *)label withCopy:(NSString *)copy andFontFamily:(NSString *)fontFamily;

+ (void)sizeLabelToFit:(UILabel *)label numberOfLines:(CGFloat)lineNumber;

+ (void)scaleAndSetBackgroundImageNamed:(NSString *)imageName forView:(UIView *)targetView;

+ (void)scaleAndSetRemoteBackgroundImage:(NSString *)remoteURL forView:(UIView *)targetView;

+ (void)formatButton:(UIButton *)button forIcon:(NSMutableAttributedString *)icon withCopy:(NSString *)buttonCopy withColor:(UIColor *)color;

+ (UIActivityIndicatorView *)setActivityIndicatorForNavItem:(UINavigationItem *)item;

+ (UIImage *)imageForURL:(NSString *)imageURL;

+ (void)rotate90Clockwise:(UIView *)object;

+ (NSAttributedString *)counterString:(NSString *)count withFontSize:(CGFloat)size;

+ (void)updateCount:(NSUInteger)number forLabel:(UILabel *)label;

+ (UILabel *)emptyTableMessage:(NSString *)message forView:(UIView *)view;

+ (void)setButtonState:(BOOL)state forButton:(UIButton *)button withBackgroundColor:(UIColor *)color andCopy:(NSString *)copy;

+ (void)roundImageLayer:(CALayer *)layer withFrame:(CGRect)frame;

+ (NSMutableAttributedString *)heartCounterStringWithCopy:(NSString *)copy andFontSize:(CGFloat)fontSize;
+ (NSMutableAttributedString *)upvoteCounterStringWithCopy:(NSString *)copy andFontSize:(CGFloat)fontSize;

+ (void)iconCounter:(NSString *)iconType withCopy:(NSString *)copy andFontSize:(CGFloat)fontSize;

+ (void)setBaseButtonStyle:(UIButton *)button withColor:(UIColor *)color;

+ (float)bodyCopyForScreenSize;

+ (float)titleCopyForScreenSize;

+ (float)buttonCopyForScreenSize;

@end
