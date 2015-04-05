//
//  FLUser.m
//  Flamey
//
//  Created by Shane Rogers on 3/21/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLUser.h"

@implementation FLUser

+(BOOL)propertyIsOptional:(NSString*)propertyName {
    return YES;
}

+(JSONKeyMapper*)keyMapper {
    return [JSONKeyMapper mapperFromUnderscoreCaseToCamelCase];
}

- (BOOL)isMale {
    return [_gender isEqualToString:@"male"];
}

- (BOOL)isFemale {
    return [_gender isEqualToString:@"female"];
}

- (NSURL *)profileURL {
    return [NSURL URLWithString:_profileImage];
}

@end
