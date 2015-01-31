//
//  FirstViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLPhotosCollectionViewController.h"
#import "FLPhotoCollectionViewCell.h"

#import "FLFacebookAlbumTableViewController.h"

// Helpers
#import "CollectionViewHelpers.h"

NSString *const kPhotoCellIdentifier = @"FLPhotoCollectionViewCell";

@interface FLPhotosCollectionViewController ()

// Convert to a store
@property (nonatomic, copy) NSMutableArray *_selectedPhotos;
@property (nonatomic, strong) UICollectionView *_collectionView;
@property (nonatomic, strong) UIScrollView *_scrollView;

@end

@implementation FLPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self renderScrollView];
    [self resetScrollContentSize];
    [self buildPhotoCollection];
}

- (void)renderScrollView {
    float height = self.view.frame.size.height - 60 - self.navigationController.navigationBar.frame.size.height;
    CGRect scrollFrame = CGRectMake(0.0f,60.0f,self.view.frame.size.width, height);
    
    self._scrollView = [[UIScrollView alloc] initWithFrame:scrollFrame];
    self._scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self._scrollView.delegate = self;

    [self.view addSubview:self._scrollView];
}

- (void)resetScrollContentSize {
    float yCoord = CGRectGetMaxY(self.view.frame);
    [self._scrollView setContentSize:CGSizeMake(self.view.frame.size.width,yCoord+50)];
}

- (void)buildPhotoCollection {
    CGRect viewFrame = self.view.frame;
    self._collectionView = [[UICollectionView alloc]initWithFrame:viewFrame collectionViewLayout:[CollectionViewHelpers buildLayoutWithWidth:viewFrame.size.width]];

    [self._collectionView registerClass:[FLPhotoCollectionViewCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
    [self._collectionView setBackgroundColor:[UIColor whiteColor]];

    // Custom cell here identifier here
    [self._collectionView setDelegate:self];
    [self._collectionView setDataSource:self];

    [self._scrollView addSubview:self._collectionView];

}

#pragma UICollectionView Protocol Methods

#pragma UITableViewDelgate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // This needs to be flexible per channel - suggestions/favorites/
    NSUInteger count = [self._selectedPhotos count];

    if(count > 0) {
        return [self._selectedPhotos count];
    } else {
        return 20;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    FLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];

    if ([self._selectedPhotos count] > 0) {
        [self removeEmptyCollectionMessage];

        // Populate cells -

//        NSObject *photo = [self._selectedPhotos objectAtIndex:[indexPath row]];
        // set cell state - unedited / edited
    }

    // Placeholdeer cells -
    [cell.editButton setTitle:@"EDIT" forState:UIControlStateNormal];
    [cell setBackgroundColor:[UIColor blueColor]];

//    [cell.backgroundView setContentMode:UIViewContentModeScaleAspectFit];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected cell %lu", (long)[indexPath row]);

    // if its the add new photos button then trigger collection picker
    [FLFacebookAlbumTableViewController showWithDelegate:self];
    // else trigger image editor
}


#pragma RFFacebookProtocol

-(void)faceBookViewController:(id)controller didSelectPhoto:(UIImage *)image
{
    NSLog(@"Callback");
}


- (void)removeEmptyCollectionMessage {
    [self._collectionView.backgroundView removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
