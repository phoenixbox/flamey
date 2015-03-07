//
//  FLTutorialViewController.h
//  Flamey
//
//  Created by Shane Rogers on 3/2/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SwipeView.h>

@interface FLTutorialViewController : UIViewController <SwipeViewDataSource, SwipeViewDelegate>

@property (strong, nonatomic) IBOutlet SwipeView *swipeView;
@property (nonatomic, strong) NSMutableArray *items;

// CONTINUE: Subclass the TutorialView and pass in a function or emit an event to trigger the segue navigation

@end