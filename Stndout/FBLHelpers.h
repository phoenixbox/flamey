//
//  FBLHelpers.h
//  Stndout
//
//  Created by Shane Rogers on 4/11/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

void    LoginUser(id target);
void    PostNotification(NSString *notification);
NSString *TimeElapsed (NSTimeInterval seconds);
UIImage* CropImage(UIImage *image, CGFloat x, CGFloat y, CGFloat width, CGFloat height);
UIImage*		SquareImage					(UIImage *image, CGFloat size);
UIImage*		ResizeImage					(UIImage *image, CGFloat width, CGFloat height);
UIImage*		CropImage					(UIImage *image, CGFloat x, CGFloat y, CGFloat width, CGFloat height);
