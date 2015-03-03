//
//  FLLoginView.h
//  Flamey
//
//  Created by Shane Rogers on 3/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FLLoginView : UIView

@property (nonatomic, copy) NSArray *images;
@property (nonatomic, strong) NSDictionary *photo;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
