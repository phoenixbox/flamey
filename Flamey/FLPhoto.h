//
//  FLPhoto.h
//  Flamey
//
//  Created by Shane Rogers on 1/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "JSONModel.h"

@protocol FLPhoto @end

@interface FLPhoto : JSONModel

@property (nonatomic) NSNumber *id;
@property (nonatomic, strong) NSString* URL;
@property (nonatomic, strong) UIImage<Optional>* image;
// Do I work?
@property (nonatomic, assign) CGPoint annotationPoint;

@end
