//
//  FBLAuth.m
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FBLAppConstants.h"

NSString* authenticateRequest(NSString *requestURL) {
    requestURL = [requestURL stringByAppendingString:(@"?token=")];
    requestURL = [requestURL stringByAppendingString:SLACK_API_KEY];

    return requestURL;
}

NSString* authenticateRequestWithURLSegment(NSString *requestURL, NSString* urlSegment) {
    if (urlSegment) {
        requestURL = [requestURL stringByAppendingString:urlSegment];
    }

    requestURL = [requestURL stringByAppendingString:(@"?token=")];
    requestURL = [requestURL stringByAppendingString:SLACK_API_KEY];

    return requestURL;
    
}

