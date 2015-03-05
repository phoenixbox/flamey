//
//  FLSelectedPhotosCollectionViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//
// Helpers
#import "CollectionViewHelpers.h"
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

NSString *const kPhotoCellIdentifier = @"FLPhotoCollectionViewCell";
NSString *const kSeguePushToImageAnnotation = @"pushToImageAnnotation";
NSString *const kSegueShowUserTutorial = @"showUserTutorial";

@interface FLSelectedPhotosCollectionViewController ()

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;
@property (assign, nonatomic) BOOL DEVELOPMENT_ENV;

@end

@implementation FLSelectedPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _DEVELOPMENT_ENV = false;
    // Do any additional setup after loading the view, typically from a nib.
    NSLog(@"Photos Count: %lu", [[FLSelectedPhotoStore sharedStore].allPhotos count]);
    FLSettings *settings = [FLSettings defaultSettings];
    settings.seenTutorial = NO;

    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    [self updateCollection];

    [self updateEditButton];

    if (!settings.seenTutorial) {
        [self performSegueWithIdentifier:kSegueShowUserTutorial sender:self];
    }
}

- (void)updateCollection {
    CGRect viewFrame = self.view.frame;
    [_selectionCollection setCollectionViewLayout:[CollectionViewHelpers buildLayoutWithWidth:viewFrame.size.width]];

    // Fetch the nib by the class name
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([FLPhotoCollectionViewCell class])
                                bundle:[NSBundle mainBundle]];
    // Register the nib
    [_selectionCollection registerNib:nib forCellWithReuseIdentifier:kPhotoCellIdentifier];
}

- (void)updateEditButton {
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

    if(count > 0) {
        [self removeEmptyCollectionMessage];
        return count;
    } else {
        [self renderEmptyMessage];
        // Local development
//        return 0;
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_DEVELOPMENT_ENV) {
        FLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];

        UIImage *testImage = [UIImage imageNamed:@"test_image"];

        cell.imageViewBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        [cell.imageViewBackgroundImage setImage:testImage];

        return cell;

    } else {
        FLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];

        FLPhoto *photo = [[FLSelectedPhotoStore sharedStore].allPhotos objectAtIndex:[indexPath row]];

        cell.imageViewBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
        [cell.imageViewBackgroundImage sd_setImageWithURL:[NSURL URLWithString:photo.URL] placeholderImage:nil];
        
        return cell;
    }
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
    [self updateEditButton];
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
