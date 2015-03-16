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

// Components
#import "FLSelectedPhotosCollectionViewController.h"
#import "FLPhotoCollectionViewCell.h"
#import "FLFacebookAlbumTableViewController.h"
#import "FLImageAnnotationViewController.h"
#import "FLSelectionCollectionEmptyMessageView.h"

NSString *const kPhotoCellIdentifier = @"FLPhotoCollectionViewCell";
NSString *const kSeguePushToImageAnnotation = @"pushToImageAnnotation";
NSString *const kSegueShowUserTutorial = @"showUserTutorial";
NSString *const kSelectionCollectionEmptyMessageView = @"FLSelectionCollectionEmptyMessageView";

@interface FLSelectedPhotosCollectionViewController ()

@end

@implementation FLSelectedPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    FLSettings *settings = [FLSettings defaultSettings];
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
    [[self navigationItem]setTitleView:nil];
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
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([FLPhotoCollectionViewCell class])
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
    NSUInteger count = [[FLSelectedPhotoStore sharedStore].allPhotos count];
    if (count == 0) {
        [_editPhotosButton setHidden:YES];
    } else {
        [_editPhotosButton setHidden:NO];
    }
}

// TODO: Allow to show the tutorial again?
//- (void)presentTutorial {
//    [self performSegueWithIdentifier:kSegueShowUserTutorial sender:self];
//}

#pragma UICollectionView Protocol Methods

#pragma UITableViewDelgate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count = [[FLSelectedPhotoStore sharedStore].allPhotos count];

    if (count > 0) {
        [_selectionCollection.backgroundView setHidden:YES];
    } else {
        [_selectionCollection.backgroundView setHidden:NO];
    }

    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];

    FLPhoto *photo = [[FLSelectedPhotoStore sharedStore].allPhotos objectAtIndex:[indexPath row]];

    cell.imageViewBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageViewBackgroundImage sd_setImageWithURL:[NSURL URLWithString:photo.URL] placeholderImage:nil];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:kSeguePushToImageAnnotation sender:self];

    NSLog(@"Push to image annotation with cell %lu", (long)[indexPath row]);
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
        annotationView.selectedPhoto = [photoStore.allPhotos objectAtIndex:[indexPath row]];
        annotationView.targetRow = [indexPath row];
    } else if ([segue isKindOfClass:[BlurryModalSegue class]]) {
        BlurryModalSegue* bms = (BlurryModalSegue*)segue;

        bms.backingImageBlurRadius = @(20);
        bms.backingImageSaturationDeltaFactor = @(.45);
        bms.backingImageTintColor = [[UIColor greenColor] colorWithAlphaComponent:.1];
    }
}

- (IBAction)unwindToSelection:(UIStoryboardSegue *)unwindSegue {
    [_selectionCollection reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [_selectionCollection reloadData];
    [self updateEditButtonVisibility];
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
@end
