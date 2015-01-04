//
//  FirstViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLPhotosCollectionViewController.h"
#import "FLPhotoCollectionViewCell.h"

NSString *const kPhotoCellIdentifier = @"FLPhotoCollectionViewCell";

@interface FLPhotosCollectionViewController ()

// Convert to a store
@property (nonatomic, copy) NSMutableArray *_selectedPhotos;
@property (nonatomic, strong) UICollectionView *_collectionView;

@end

@implementation FLPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self buildPhotoCollection];
}

- (void)buildPhotoCollection {
    self._collectionView = [[UICollectionView alloc]initWithFrame:self.scrollView.bounds collectionViewLayout:[self buildCollectionViewCellLayout]];

    [self._collectionView registerClass:[FLPhotoCollectionViewCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
    [self._collectionView setBackgroundColor:[UIColor whiteColor]];

    // Custom cell here identifier here
    [self._collectionView setDelegate:self];
    [self._collectionView setDataSource:self];

    [self.scrollView addSubview:self._collectionView];

}

- (UICollectionViewFlowLayout *)buildCollectionViewCellLayout {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 5.0f;
    flowLayout.minimumInteritemSpacing = 5.0f;
    flowLayout.itemSize = CGSizeMake(102.5f,102.5f);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(2.5f, 0.0f, 2.5f, 0.0f);

    return flowLayout;
}

#pragma UICollectionView Protocol Methods

#pragma UITableViewDelgate

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    // This needs to be flexible per channel - suggestions/favorites/
    NSUInteger count = [self._selectedPhotos count];

    if(count > 0) {
        return [self._selectedPhotos count];
    } else {
        return 1;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    FLPhotoCollectionViewCell *cell = (FLPhotoCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotoCellIdentifier forIndexPath:indexPath];

    if ([self._selectedPhotos count] > 0) {
        [self removeEmptyCollectionMessage];

//        NSObject *photo = [self._selectedPhotos objectAtIndex:[indexPath row]];
        // set cell state - unedited / edited
    }

    [cell setBackgroundColor:[UIColor redColor]];

//    [cell.backgroundView setContentMode:UIViewContentModeScaleAspectFit];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected cell %lu", [indexPath row]);


//    // Create the image editor controller
//    FLImageEditorController *imageEditorController = [[FLImageEditorController alloc] init];
//    // Retrieve the right model
//    FLPhoto *selectedPhoto = [self._selectedPhotos objectAtIndex:[indexPath row]];
//    // Set that model on the instantiated controller
//    [imageEditorController setViewWithImage:selectedPhoto];

// Push that controller on the navigation controlller
//    [[self navigationController] pushViewController:imageEditorController animated:YES];
}


- (void)removeEmptyCollectionMessage {
    [self._collectionView.backgroundView removeFromSuperview];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
