//
//  FBLAuth.h
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <Foundation/Foundation.h>

NSString* authenticateRequest(NSString *requestURL);

NSString* authenticateRequestWithURLSegment(NSString *requestURL, NSString* urlSegment);
