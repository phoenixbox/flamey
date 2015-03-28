//
//  FLSelectedPhotosCollectionViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//
// Helpers
#import "CollectionViewHelpers.h"
#import "FLViewHelpers.h"
#import <UIKit/UIKit.h>

// Data layer
#import "FLSelectedPhotoStore.h"
#import "FLSettings.h"

// Pods
#import <SDWebImage/UIImageView+WebCache.h>
#import "BlurryModalSegue.h"
#import <SIAlertView.h>

// Components
#import "FLSelectedPhotosCollectionViewController.h"
#import "FLFacebookPhotoCollectionViewCell.h"

#import "FLFacebookAlbumTableViewController.h"
#import "FLImageAnnotationViewController.h"
#import "FLSelectionCollectionEmptyMessageView.h"

NSString *const kPhotoCellIdentifier = @"FLFacebookPhotoCollectionViewCell";
NSString *const kSeguePushToImageAnnotation = @"pushToImageAnnotation";
NSString *const kSegueShowUserTutorial = @"showUserTutorial";
NSString *const kSelectionCollectionEmptyMessageView = @"FLSelectionCollectionEmptyMessageView";
NSString *const kDoneEditingTitle = @"Done";
NSString *const kStartEditingTitle = @"Edit";

@interface FLSelectedPhotosCollectionViewController ()

@property (nonatomic, assign) BOOL inEditMode;

@end

@implementation FLSelectedPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FLSettings *settings = [FLSettings defaultSettings];
    // TODO: Remove the hard set here
    settings.seenTutorial = NO;

    self.navigationController.navigationBar.translucent = NO;
    [self updateCollection];

    [FLViewHelpers setBaseButtonStyle:_editPhotosButton withColor:[UIColor blackColor]];
    [self updateEditButtonVisibility];

    [self setHeaderLogo];

    if (!settings.seenTutorial) {
        [self performSegueWithIdentifier:kSegueShowUserTutorial sender:self];
    }

    [self listenForGetFacebookPhotosNotification];
}

- (void)setHeaderLogo {
    [[self navigationItem] setTitleView:nil];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    self.navigationItem.titleView = logoView;
}

- (void)listenForGetFacebookPhotosNotification {
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];

    [center addObserver:self
               selector:@selector(getFacebookPhotos)
                   name:kGetFacebookPhotos
                 object:nil];
}

- (void)getFacebookPhotos {
    [self performSegueWithIdentifier:kGetFacebookPhotos sender:self];
}

- (void)updateCollection {
    CGRect viewFrame = self.view.frame;
    [_selectionCollection setCollectionViewLayout:[CollectionViewHelpers buildLayoutWithWidth:viewFrame.size.width]];

    // Fetch the nib by the class name
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([FLFacebookPhotoCollectionViewCell class])
                                bundle:[NSBundle mainBundle]];
    // Register the nib
    [_selectionCollection registerNib:nib forCellWithReuseIdentifier:kPhotoCellIdentifier];

    [self setCollectionViewBackgroundView];
}

- (void)setCollectionViewBackgroundView {
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:kSelectionCollectionEmptyMessageView owner:nil options:nil];
    FLSelectionCollectionEmptyMessageView *emptyMessage = [nibContents lastObject];
    emptyMessage.contentView.layer.cornerRadius = 4;
    emptyMessage.contentView.layer.borderWidth = 1;
    emptyMessage.contentView.layer.borderColor = [UIColor blackColor].CGColor;
    [emptyMessage.contentView setBackgroundColor:[UIColor whiteColor]];

    [FLViewHelpers setBaseButtonStyle:emptyMessage.getFacebookPhotosButton withColor:[UIColor blackColor]];
    [_selectionCollection setBackgroundView:emptyMessage];
    // Show empty message by default
    [_selectionCollection.backgroundView setHidden:NO];
}

- (void)updateEditButtonVisibility {
    NSUInteger count = [[FLSelectedPhotoStore sharedStore].photos count];
    if (count == 0) {
        [_editPhotosButton setHidden:YES];
    } else {
        [_editPhotosButton setHidden:NO];
    }
}

#pragma UICollectionView Protocol Methods

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count = [[FLSelectedPhotoStore sharedStore].photos count];

    if (count > 0) {
        [_selectionCollection.backgroundView setHidden:YES];
    } else {
        [_selectionCollection.backgroundView setHidden:NO];
    }

    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FLFacebookPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];

    FLPhoto *photo = [[FLSelectedPhotoStore sharedStore].photos objectAtIndex:[indexPath row]];

    cell.imageViewBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageViewBackgroundImage sd_setImageWithURL:[NSURL URLWithString:photo.URL] placeholderImage:[UIImage imageNamed:@"Persona"]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_inEditMode) {
        // Remove the photo from the selection store
        FLSelectedPhotoStore *selectedStore = [FLSelectedPhotoStore sharedStore];
        [selectedStore.photos removeObjectAtIndex:[indexPath row]];

        [_selectionCollection deleteItemsAtIndexPaths:@[indexPath]];
        if ([selectedStore.photos count] == 0) {
            [_editPhotosButton setHidden:YES];
            [self turnOffEditing];
        }
    } else {
        [self performSegueWithIdentifier:kSeguePushToImageAnnotation sender:self];

        NSLog(@"Push to image annotation with cell %lu", (long)[indexPath row]);
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:kSeguePushToImageAnnotation]) {
        NSIndexPath *indexPath = [[_selectionCollection indexPathsForSelectedItems] lastObject];
        FLSelectedPhotoStore *photoStore = [FLSelectedPhotoStore sharedStore];

//      Retrieve the target view controller
        UINavigationController *vc = segue.destinationViewController;
//      Retrieve its child view controller
        FLImageAnnotationViewController *annotationView = [vc.viewControllers objectAtIndex:0];
//      Attribute it
        annotationView.selectedPhoto = [photoStore.photos objectAtIndex:[indexPath row]];
        annotationView.targetRow = [indexPath row];
    } else if ([segue isKindOfClass:[BlurryModalSegue class]]) {
        BlurryModalSegue* bms = (BlurryModalSegue*)segue;

        bms.backingImageBlurRadius = @(20);
        bms.backingImageSaturationDeltaFactor = @(.45);
        bms.backingImageTintColor = [[UIColor greenColor] colorWithAlphaComponent:.1];
    }
}

- (void)toggleCollectionEditMode {
    if (_inEditMode) {
        for (FLFacebookPhotoCollectionViewCell *cell in     _selectionCollection.visibleCells) {
            [cell setEditable:YES];
        }
    } else {
        for (FLFacebookPhotoCollectionViewCell *cell in     _selectionCollection.visibleCells) {
            [cell setEditable:NO];
        }
    }
}

- (IBAction)unwindToSelection:(UIStoryboardSegue *)unwindSegue {
}

- (void)viewWillAppear:(BOOL)animated {
    // TODO: Update the name of this to be marker button
    // compose all state handlers to one branching function
    [self turnOffEditing];
    [self toggleCollectionEditMode];
    [self updateEditButtonVisibility];
    [_selectionCollection reloadData];
}

#pragma RFFacebookProtocol

-(void)faceBookViewController:(id)controller didSelectPhoto:(UIImage *)image
{
    NSLog(@"Callback");
}

- (void)removeEmptyCollectionMessage {
    _selectionCollection.backgroundView = nil;
}

- (void)renderEmptyMessage {
    [CollectionViewHelpers renderEmptyMessage:@"Tap \"Add\" to select some of your Facebook photos to edit" forCollectionView:_selectionCollection];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editPhotos:(id)sender {
    [self performSegueWithIdentifier:kSeguePushToImageAnnotation sender:self];
}

- (void)turnOnEditing {
    _inEditMode = YES;
    [_editCollectionButton setTitle:kDoneEditingTitle];
}

- (void)turnOffEditing {
    _inEditMode = NO;
    [_editCollectionButton setTitle:kStartEditingTitle];
}

- (IBAction)editCollection:(id)sender {
    FLSelectedPhotoStore *selectedStore = [FLSelectedPhotoStore sharedStore];
    if ([selectedStore photosPresent]) {
        if ([_editCollectionButton.title isEqualToString:kStartEditingTitle]) {
            [self turnOnEditing];
        } else {
            [self turnOffEditing];
        }
        [self toggleCollectionEditMode];
    } else {
        [self promptToAddPhotos];
    }
}

- (void)promptToAddPhotos {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Oops no Photos!" andMessage:@"Get some Facebook photos"];

    [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];
    [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

    [alertView addButtonWithTitle:@"Lets Go!"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                            [self performSegueWithIdentifier:kGetFacebookPhotos sender:self];
                          }];

    [alertView addButtonWithTitle:@"Not Now"
                             type:SIAlertViewButtonTypeCancel
                          handler:^(SIAlertView *alert) {
                              NSLog(@"Hide Selected Collection Alert");
                          }];

    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

    [alertView show];
}


@end
