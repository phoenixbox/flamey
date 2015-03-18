//
//  LoginViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView.h>

#import <FacebookSDK/FacebookSDK.h>

@interface FLLoginViewController : UIViewController <FBLoginViewDelegate, UIScrollViewDelegate, SwipeViewDataSource, SwipeViewDelegate>
@property (strong, nonatomic) IBOutlet FBLoginView *loginView;

@property (weak, nonatomic) IBOutlet SwipeView *swipeView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)pageControlled:(id)sender;

@end