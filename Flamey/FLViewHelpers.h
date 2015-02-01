//
//  FLViewHelpers.h
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FontAwesomeKit/FAKFontAwesome.h"

@interface FLViewHelpers : NSObject

+ (NSMutableAttributedString *)createIcon:(FAKFontAwesome *)icon withColor:(UIColor *)color;

@end
