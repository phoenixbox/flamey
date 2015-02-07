//
//  FLSelectedPhotosCollectionViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//
// Helpers
#import "CollectionViewHelpers.h"

// Data layer
#import "FLPhotoStore.h"

// Pods
#import <SDWebImage/UIImageView+WebCache.h>

// Components
#import "FLSelectedPhotosCollectionViewController.h"
#import "FLPhotoCollectionViewCell.h"
#import "FLFacebookAlbumTableViewController.h"
#import "FLImageFilterViewController.h"

NSString *const kPhotoCellIdentifier = @"FLPhotoCollectionViewCell";

@interface FLSelectedPhotosCollectionViewController ()

@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation FLSelectedPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
    [self updateCollection];
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

#pragma UICollectionView Protocol Methods

#pragma UITableViewDelgate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    NSUInteger count = [[FLPhotoStore sharedStore].allPhotos count];

    if(count > 0) {
        [self removeEmptyCollectionMessage];
        return count;
    } else {
        [self renderEmptyMessage];
        return 0;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];

    FLPhoto *photo = [[FLPhotoStore sharedStore].allPhotos objectAtIndex:[indexPath row]];

    cell.imageViewBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageViewBackgroundImage sd_setImageWithURL:[NSURL URLWithString:photo.URL] placeholderImage:nil];

    return cell;
}

//- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    FLPhotoStore *photoStore = [FLPhotoStore sharedStore];
//    FLPhoto *selectedPhoto = [photoStore.allPhotos objectAtIndex:[indexPath row]];
//
//    FLImageFilterViewController *filterView = [FLImageFilterViewController new];
//
//    [filterView.photoImageView sd_setImageWithURL:[NSURL URLWithString:selectedPhoto.URL] placeholderImage:nil];
//    [self presentViewController:filterView animated:YES completion:nil];

//    NSLog(@"Selected cell %lu", (long)[indexPath row]);
//}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"pushToImageEditor"]) {
        NSIndexPath *indexPath = [[_selectionCollection indexPathsForSelectedItems] lastObject];
        FLPhotoStore *photoStore = [FLPhotoStore sharedStore];
        FLPhoto *selectedPhoto = [photoStore.allPhotos objectAtIndex:[indexPath row]];

        FLImageFilterViewController *filterView = segue.destinationViewController;
        [filterView.photoImageView sd_setImageWithURL:[NSURL URLWithString:selectedPhoto.URL] placeholderImage:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated {
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

@end
