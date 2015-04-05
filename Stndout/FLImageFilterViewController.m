  //
//  FLImageFilterViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/31/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLImageFilterViewController.h"

// Pods
#import <SDWebImage/UIImageView+WebCache.h>

// Components
#import "FLFilterTableViewCell.h"

// Constants
#import "FLStyleConstants.h"
#import "FLComponentConstants.h"
#import "FLViewHelpers.h"

// If just using the reference images we dont need the other filter imports
#import "GPUImageLookupFilter.h"
#import "GPUImagePicture.h"
#import "GPUImageBrightnessFilter.h"

// Data Layer
#import "FLFiltersStore.h"

NSString *const kFiltersTable = @"filtersTable";
NSString *const kToolsTable = @"toolsTable";

@interface FLImageFilterViewController ()

@property (nonatomic, strong) UITableView *lateralTable;
@property (nonatomic, assign) float cellWidth;
@property (nonatomic, strong) UILongPressGestureRecognizer *imageViewLongPress;
@property (nonatomic, strong) UIImage *facebookImage;
@property (nonatomic, strong) UIImage *cachedImage;
@property (nonatomic, strong) NSString *currentTableType;
@property (nonatomic, strong) NSString *selectedToolType;
@property (nonatomic, strong) NSMutableDictionary *sliderValues;
@property (nonatomic, strong) UITapGestureRecognizer *imageViewTap;

@property (nonatomic, strong) GPUImageOutput<GPUImageInput> *filter;

@end

@implementation FLImageFilterViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        _currentTableType = kFiltersTable;

        _sliderValues = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                              nil, [NSNumber numberWithInt: ART_ADJUST],
                              nil, [NSNumber numberWithInt: ART_BRIGHTNESS],
                              nil, [NSNumber numberWithInt: ART_CONTRAST],
                              nil, [NSNumber numberWithInt: ART_HIGHLIGHTS],
                              nil, [NSNumber numberWithInt: ART_SHADOWS],
                              nil, [NSNumber numberWithInt: ART_SATURATION],
                              nil, [NSNumber numberWithInt: ART_VIGNETTE],
                              nil, [NSNumber numberWithInt: ART_WARMTH],
                              nil, [NSNumber numberWithInt: ART_TILTSHIFT],
                              nil, [NSNumber numberWithInt: ART_SHARPEN], nil];
    }
    return self;
}

- (void)addTapGestureRecogniserToImageView {
    NSLog(@"SETTING");
    self.imageViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(setFlameIcon:)];
    self.imageViewTap.numberOfTouchesRequired = 1;
    self.imageViewTap.numberOfTapsRequired = 1;

    [_photoImageView addGestureRecognizer:self.imageViewTap];
    // NOTE: Must set interaction true so that the gesture can be triggered. Dont have to have selector on the filter ImageView
    _photoImageView.userInteractionEnabled = YES;
}

- (void)setFlameIcon:(UIGestureRecognizer *)gr {
    NSLog(@"Recognized tap");

    // Base Image
    GPUImagePicture *inputGPUImage = [[GPUImagePicture alloc] initWithImage:_facebookImage];

    // Flame Image
    CGPoint point = [gr locationInView:_photoImageView];
    UIImage *overlayImage = [self createFlame:_photoImageView.frame.size atTouchPoint:point];
    GPUImagePicture *flameyGPUImage = [[GPUImagePicture alloc] initWithImage:overlayImage];

    // 2. Set up the filter chain
    GPUImageAlphaBlendFilter * alphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    alphaBlendFilter.mix = 1.0;

    [inputGPUImage addTarget:alphaBlendFilter atTextureLocation:0];
    [flameyGPUImage addTarget:alphaBlendFilter atTextureLocation:1];

    [alphaBlendFilter useNextFrameForImageCapture];
    [inputGPUImage processImage];
    [flameyGPUImage processImage];

    UIImage *processedImage = [alphaBlendFilter imageFromCurrentFramebuffer];

    [_photoImageView setImage:processedImage];
}

- (UIImage *)createFlame:(CGSize)inputSize atTouchPoint:(CGPoint)touchPoint {
    UIImage * ghostImage = [UIImage imageNamed:@"ghost.png"];

    CGFloat flameyIconAspectRatio = ghostImage.size.width / ghostImage.size.height;

    NSInteger targetFlameyWidth = inputSize.width * 0.2;
    CGSize flameSize = CGSizeMake(targetFlameyWidth, targetFlameyWidth / flameyIconAspectRatio);

    // TODO: This is an incorrect way to adjust for touch recognition offset
    CGPoint newPoint = CGPointMake(touchPoint.x * 0.85, touchPoint.y * 0.85);

    CGRect flameRect = {newPoint, flameSize};

    UIGraphicsBeginImageContext(inputSize);
    CGContextRef context = UIGraphicsGetCurrentContext();

    CGRect inputRect = {CGPointZero, inputSize};
    CGContextClearRect(context, inputRect);

    CGAffineTransform flip = CGAffineTransformMakeScale(1.0, -1.0);
    CGAffineTransform flipThenShift = CGAffineTransformTranslate(flip,0,-inputSize.height);
    CGContextConcatCTM(context, flipThenShift);
    CGRect transformedGhostRect = CGRectApplyAffineTransform(flameRect, flipThenShift);

    CGContextDrawImage(context, transformedGhostRect, [ghostImage CGImage]);

    UIImage *flameyIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return flameyIcon;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _cellWidth = self.view.frame.size.width * 0.25;

    [self renderLateralTable];

    [self hideAndLowerSliderView];

    [_photoImageView sd_setImageWithURL:[NSURL URLWithString:self.selectedPhoto.URL] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"Photo image view present");
        _facebookImage = image;

        FLFiltersStore *filterStore = [FLFiltersStore sharedStore];
        [filterStore generateFiltersForImage:_facebookImage];

        FLToolsStore *toolStore = [FLToolsStore sharedStore];
        [toolStore generateToolOptions];

        [self addTapGestureRecogniserToImageView];
    }];
}

- (void)addFilterImageViewEventHandlers {
    _imageViewLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOriginalImage:)];
    _imageViewLongPress.numberOfTouchesRequired = 1;
    _imageViewLongPress.allowableMovement = 100.0f;
    _imageViewLongPress.minimumPressDuration = 0.075; /* Add this gesture recognizer to our view */

    [_photoImageView addGestureRecognizer:_imageViewLongPress];
    // NOTE: Must set interaction true so that the gesture can be triggered. Dont have to have selector on the filter ImageView
    _photoImageView.userInteractionEnabled = YES;
}

- (void)toggleOriginalImage:(UIGestureRecognizer *)recognizer {
    UIGestureRecognizerState state = [recognizer state];

    if (state == UIGestureRecognizerStateBegan) {
        // Cache the last stateful image
        _cachedImage = [_photoImageView image];
        // Show the original
        [_photoImageView setImage:_photoImageView.image];
    } else if (state == UIGestureRecognizerStateCancelled || state == UIGestureRecognizerStateFailed || state == UIGestureRecognizerStateEnded) {
        // Reset the imageView with the cached image
        [_photoImageView setImage:_cachedImage];
    }
}

- (void)hideAndLowerSliderView {
    [_sliderView setHidden:YES];
    [self.view sendSubviewToBack:_sliderView];
}

- (void)showAndRaiseSliderView {
    [_sliderView setHidden:NO];
    [self.view bringSubviewToFront:_sliderView];
}

- (void)toggleTableViewCellsTo:(NSString *)identifier {
    _currentTableType = identifier;
    [_lateralTable reloadData];
}

- (void)renderLateralTable {
    _lateralTable = [UITableView new];
    CGFloat tableY = CGRectGetMaxY(self.view.frame) * 0.8;
    CGRect piecesRect = CGRectMake(0.0f,
                                   tableY,
                                   CGRectGetMaxX(self.view.frame),
                                   CGRectGetMaxY(self.view.frame) * 0.2);

    _lateralTable = [[UITableView alloc] initWithFrame:piecesRect];
    CGAffineTransform rotate = CGAffineTransformMakeRotation(-M_PI_2);
    [_lateralTable setTransform:rotate];
    // VIP: Must set the frame again on the table after rotation
    [_lateralTable setFrame:piecesRect];
    [_lateralTable registerClass:[UITableViewCell class] forCellReuseIdentifier:kFLFilterTableViewCellIdentifier];
    _lateralTable.delegate = self;
    _lateralTable.dataSource = self;
    _lateralTable.alwaysBounceVertical = NO;
    _lateralTable.scrollEnabled = YES;
    _lateralTable.showsVerticalScrollIndicator = NO;
    _lateralTable.separatorInset = UIEdgeInsetsMake(0, 3, 0, 3);
    [_lateralTable setSeparatorColor:[UIColor clearColor]];

    [_lateralTable setBackgroundColor:[UIColor grayColor]];

    [self.view addSubview:_lateralTable];
}

#pragma UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self isFiltersTable]) {
        FLFiltersStore *filterStore = [FLFiltersStore sharedStore];

        return [[filterStore allFilters] count];
    } else if ([self isToolsTable]) {
        FLToolsStore *toolStore = [FLToolsStore sharedStore];

        return [[toolStore allTools] count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLFiltersStore *filterStore = [FLFiltersStore sharedStore];
    FLToolsStore *toolStore = [FLToolsStore sharedStore];

    // Load the custom xib
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kFLFilterTableViewCellIdentifier owner:nil options:nil];
    FLFilterTableViewCell *cell = [nibContents lastObject];

    if([tableView isEqual:_lateralTable]){

        if ([self isFiltersTable]) {
            NSDictionary *attributes = [[filterStore allFilters] objectAtIndex:[indexPath row]];

            [cell.overlayLabel setHidden:NO];
            [cell setCellImage:[attributes objectForKey:@"blurredImage"]];
            [cell setOverlayImage:[attributes objectForKey:@"overlay"]];
            [cell setCellLabel:[attributes objectForKey:@"filterName"]];

        } else if ([self isToolsTable]) {
            NSDictionary *attributes = [[toolStore allTools] objectAtIndex:[indexPath row]];

            NSString *toolType = [attributes objectForKey:@"toolName"];
            [cell.overlayLabel setHidden:YES];
            [cell setCellImage:[attributes objectForKey:@"toolIcon"]];
            [cell setCellLabel:toolType];
        }

        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        
        if ([indexPath row] > 0) {
            [cell.selectionIndicator setHidden:YES];
        }
    }
    return cell;
}

- (BOOL)isFiltersTable {
    return [_currentTableType isEqual:kFiltersTable];
}

- (BOOL)isToolsTable {
    return [_currentTableType isEqual:kToolsTable];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return _cellWidth;
}

// NOTE: Auto select the first cell so we can trigger removal of the selection indicator on first alternate row selection
- (void)viewWillAppear:(BOOL)animated {
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [_lateralTable selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionBottom];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLFilterTableViewCell *cell = (FLFilterTableViewCell *)[_lateralTable cellForRowAtIndexPath:indexPath];
    [cell.selectionIndicator setHidden:NO];

    if ([self isFiltersTable]) {
        FLFiltersStore *filterStore = [FLFiltersStore sharedStore];
        NSDictionary *targetFilter = [filterStore.allFilters objectAtIndex:[indexPath row]];

        _photoImageView.image = [targetFilter objectForKey:@"filteredImage"];
    } else if ([self isToolsTable]) {
        // Update the cached image
        FLToolsStore *toolStore = [FLToolsStore sharedStore];
        _facebookImage = [_photoImageView image];

        filterType = (ARTToolType)indexPath.row;

        [FLToolsStore setupSlider:self.slider forFilterType:(ARTToolType)indexPath.row];

        float lastValue = [[_sliderValues objectForKey:[NSNumber numberWithInt:filterType]] floatValue];

        if (lastValue != 0) { // If last value is nil
            [self.slider setValue:lastValue];
        }

        NSDictionary *attributes = [[toolStore allTools] objectAtIndex:[indexPath row]];

        [_selectedFilterImage setImage:[attributes objectForKey:@"toolIcon"]];
        [_selectedFilterName setText:[attributes objectForKey:@"toolName"]];

        [self showAndRaiseSliderView];
        [_lateralTable setHidden:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    FLFilterTableViewCell *cell = (FLFilterTableViewCell *)[_lateralTable cellForRowAtIndexPath:indexPath];

    [cell.selectionIndicator setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

- (IBAction)goBack:(id)sender {
    NSLog(@"goBack");
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)saveImage:(id)sender {
    NSLog(@"goNext");
}

- (IBAction)revealFilters:(id)sender {
    if (![self isFiltersTable]) {
        [self toggleTableViewCellsTo:kFiltersTable];
    } else {
        NSLog(@"Filters already set");
    }
}

- (IBAction)revealBrightness:(id)sender {
    NSLog(@"revealBrightness");
}

- (IBAction)revealTools:(id)sender {
    if (![self isToolsTable]) {
        [self toggleTableViewCellsTo:kToolsTable];
    } else {
        NSLog(@"Tools already set");
    }
}

- (IBAction)sliding:(id)sender {
    float sliderValue = (float)[(UISlider *)sender value];
    [_sliderValues setObject:[NSNumber numberWithFloat:sliderValue] forKey:[NSNumber numberWithInt:filterType]];

    // Note: initialize the source with a cached instance of the image :)
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:_facebookImage];

    switch (filterType)
    {
        case ART_ADJUST: {
            self.filter = [GPUImageTransformFilter new];
            [(GPUImageTransformFilter *)self.filter setAffineTransform:CGAffineTransformMakeRotation(sliderValue)];
        }; break;
        case ART_BRIGHTNESS: {
            self.filter = [GPUImageBrightnessFilter new];
            [(GPUImageBrightnessFilter *)self.filter setBrightness:sliderValue];
        }; break;
        case ART_CONTRAST: {
            self.filter = [GPUImageContrastFilter new];
            [(GPUImageContrastFilter *)self.filter setContrast:sliderValue];
        }; break;
        case ART_HIGHLIGHTS: {
            self.filter = [GPUImageHighlightShadowFilter new];
            [(GPUImageHighlightShadowFilter *)self.filter setHighlights:[(UISlider *)sender value]];
        }; break;
        case ART_SHADOWS: {
            self.filter = [GPUImageHighlightShadowFilter new];
            [(GPUImageHighlightShadowFilter *)self.filter setShadows:[(UISlider *)sender value]];
        }; break;
        case ART_SATURATION: {
            self.filter = [GPUImageSaturationFilter new];
            [(GPUImageSaturationFilter *)self.filter setSaturation:sliderValue];
        }; break;
        case ART_VIGNETTE: {
            self.filter = [GPUImageVignetteFilter new];
            //            self.vignetteStart = 0.3;
            //            self.vignetteEnd = 0.75;
            [(GPUImageVignetteFilter *)self.filter setVignetteStart:0.35];
            [(GPUImageVignetteFilter *)self.filter setVignetteEnd:1.4-sliderValue];
        }; break;
        case ART_WARMTH: {
            self.filter = [GPUImageWhiteBalanceFilter new];
            [(GPUImageWhiteBalanceFilter *)self.filter setTemperature:sliderValue];
        }; break;
        case ART_TILTSHIFT: {
            self.filter = [[GPUImageTiltShiftFilter alloc] init];
            [(GPUImageTiltShiftFilter *)self.filter setTopFocusLevel:0.4];
            [(GPUImageTiltShiftFilter *)self.filter setBottomFocusLevel:0.6];
            [(GPUImageTiltShiftFilter *)self.filter setFocusFallOffRate:0.2];

            [(GPUImageTiltShiftFilter *)self.filter setTopFocusLevel:sliderValue - 0.1];
            [(GPUImageTiltShiftFilter *)self.filter setBottomFocusLevel:sliderValue + 0.1];
        }; break;
        case ART_SHARPEN: {
            self.filter = [GPUImageSharpenFilter new];
            [(GPUImageSharpenFilter *)self.filter setSharpness:sliderValue];
        }; break;
        default: break;
    }

    [stillImageSource addTarget:self.filter];
    [self.filter useNextFrameForImageCapture];
    [stillImageSource processImage];

    _photoImageView.image = [self.filter imageFromCurrentFramebuffer];;
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"Required for an unwinding segue");
}

- (IBAction)cancelAdjustment:(id)sender {
    NSLog(@"cancelAdjustment");
    [self.sliderView setHidden:YES];
    [_lateralTable setHidden:NO];
}

- (IBAction)saveAdjustment:(id)sender {
    NSLog(@"saveAdjustment");
    [self.sliderView setHidden:YES];
}

@end