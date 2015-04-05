//
//  FLImageFilterViewController.h
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FLFilterSlider.h"
#import "FLFilterHelpers.h"
#import "FLToolsStore.h"
#import "FLPhoto.h"

@interface FLImageFilterViewController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    ARTToolType filterType;
}

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;

// ADJUSTMENTS
@property (strong, nonatomic) IBOutlet UIView *adjustmentsView;

@property (strong, nonatomic) IBOutlet UIButton *filtersButton;
- (IBAction)revealFilters:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *brightnessButton;
- (IBAction)revealBrightness:(id)sender;

@property (strong, nonatomic) IBOutlet UIButton *toolsButton;
- (IBAction)revealTools:(id)sender;

// SLIDER
@property (strong, nonatomic) IBOutlet UIView *sliderView;
- (IBAction)sliding:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *cancelAdjustmentButton;
- (IBAction)cancelAdjustment:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *saveAdjustmentButton;
- (IBAction)saveAdjustment:(id)sender;
@property (strong, nonatomic) IBOutlet UISlider *slider;

// Selected Filter information
@property (weak, nonatomic) IBOutlet UIImageView *selectedFilterImage;
@property (weak, nonatomic) IBOutlet UILabel *selectedFilterName;
@property (weak, nonatomic) IBOutlet UILabel *selectedFilterInformation;

@property (nonatomic, strong) FLPhoto *selectedPhoto;

@end