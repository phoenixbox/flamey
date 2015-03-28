//
//  FLAnnotationTableEmptyMessageView.m
//  Flamey
//
//  Created by Shane Rogers on 3/7/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLAnnotationTableEmptyMessageView.h"

NSString *const kAddMorePhotos = @"addMorePhotos";
NSString *const kRefreshCollection = @"refreshCollection";

@implementation FLAnnotationTableEmptyMessageView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (IBAction)addPhotos:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:kAddMorePhotos
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (IBAction)refreshCollection:(id)sender {
    NSNotification *notification = [NSNotification notificationWithName:kRefreshCollection
                                                                 object:self];

    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

@end
