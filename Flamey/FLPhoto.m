//
//  FLPhoto.m
//  Flamey
//
//  Created by Shane Rogers on 1/18/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLPhoto.h"

@implementation FLPhoto

+(BOOL)propertyIsOptional:(NSString*)propertyName {
    if ([propertyName isEqualToString: @"annotationPoint"]) {
        return YES;
    } else if ([propertyName isEqualToString: @"logoPoint"]) {
        return YES;
    }
    
    return NO;
}

@end
