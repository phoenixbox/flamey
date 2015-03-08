//
//  FLSelectionCollectionEmptyMessageView.m
//  Flamey
//
//  Created by Shane Rogers on 3/7/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLSelectionCollectionEmptyMessageView.h"

NSString *const kGetFacebookPhotos = @"getFacebookPhotos";

@implementation FLSelectionCollectionEmptyMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)getFacebookPhotos:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:kGetFacebookPhotos object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}
@end
