//
//  FLFacebookPhotoCollectionViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/17/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookPhotoPickerViewController.h"
#import "FLFacebookPhotoCollectionViewCell.h"
#import <FacebookSDK/FacebookSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FLPhotoCollectionViewCell.h"

#import "FLPhotoStore.h"
#import "FLPhoto.h"

@interface FLFacebookPhotoPickerViewController ()

@property (strong) NSMutableArray* datasource;
@property (strong) UICollectionView* collectionView;

@end

@implementation FLFacebookPhotoPickerViewController

static NSString * const cellIdentifier = @"FLFacebookPhotoCollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    _datasource = [[NSMutableArray alloc] init];

    [self buildPhotoCollection];
    [self sendRequest];
}

- (void)buildPhotoCollection {
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.frame collectionViewLayout:[self buildCollectionViewCellLayout]];

    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[FLFacebookPhotoCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];

    // Custom cell here identifier here
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];

    [self.view addSubview:_collectionView];
}

- (UICollectionViewFlowLayout *)buildCollectionViewCellLayout {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 2.5f;
    flowLayout.minimumInteritemSpacing = 2.5f;
    CGFloat cellSize = (self.view.frame.size.width - 5)/3;
    flowLayout.itemSize = CGSizeMake(cellSize,cellSize);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(2.5f, 0.0f, 2.5f, 0.0f);

    return flowLayout;
}

//- (void)configureCollectionView {
//    CGFloat const inset = 0;
//    CGFloat const eachLineCount = 4.0;
//    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
//    flowLayout.minimumInteritemSpacing = inset;
//    flowLayout.minimumLineSpacing = inset;
//    flowLayout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
//    CGFloat width = (CGRectGetWidth(self.view.bounds)-(eachLineCount+1)*inset)/eachLineCount;
//    flowLayout.itemSize = CGSizeMake(width, width);
//
//    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
//    _collectionView.delegate = self;
//    _collectionView.dataSource = self;
//    _collectionView.allowsMultipleSelection = YES;
//    _collectionView.alwaysBounceVertical = YES;
////    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
//    _collectionView.backgroundColor = [UIColor whiteColor];
//    [_collectionView registerClass:[FLFacebookPhotoCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
//    [self.view addSubview:_collectionView];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendRequest {
    // TODO: Update to a less brittle interface
    if(_albumId){
        NSString* graphPath = [NSString stringWithFormat:@"/%@?fields=photos", _albumId];

        [FBRequestConnection startWithGraphPath:graphPath
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {

                                  NSDictionary* resultDict = (NSDictionary*)result;
                                  NSDictionary* dict  = [resultDict objectForKey:@"photos"];
                                  NSArray* array = [dict objectForKey:@"data"];

                                  [self addImagesToDataSource:array];
        }];
    } else {
        [FBRequestConnection startWithGraphPath:@"/me/photos"
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {

                                  NSDictionary* resultDict = (NSDictionary*)result;
                                  NSArray* array = [resultDict objectForKey:@"data"];
                                  [self addImagesToDataSource:array];
                              }];
    }
}

- (void)addImagesToDataSource:(NSArray *)images {
    for (NSDictionary* innerDict in images) {
        NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[innerDict objectForKey:@"id"], @"id" , [innerDict objectForKey:@"source"], @"URL", nil];

        [_datasource addObject:dict];
    }
    [_collectionView reloadData];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _datasource.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.imageView.clipsToBounds = YES;
    [cell.imageView setUserInteractionEnabled:YES];

    NSString *remoteURL = [_datasource[indexPath.row] objectForKey:@"URL"];

    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:remoteURL] placeholderImage:nil];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedPhoto = _datasource[indexPath.row];

    FLPhoto *photo = [[FLPhoto alloc] initWithDictionary:selectedPhoto error:nil];
    [[FLPhotoStore sharedStore] addUniquePhoto:photo];

    NSLog(@"Selected collection image");
    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
//    if (_delegate) {
//        UICollectionViewCell* cell = [collectionView cellForItemAtIndexPath:indexPath];
//        UIImageView* imageView = (UIImageView*)[cell viewWithTag:100];
//        [_delegate faceBookViewController:self didSelectPhoto:imageView.image];
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
}


#pragma mark <UICollectionViewDelegate>

/*
// Uncomment this method to specify if the specified item should be highlighted during tracking
- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
	return YES;
}
*/

/*
// Uncomment this method to specify if the specified item should be selected
- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}
*/

/*
// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	return NO;
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
	
}
*/

@end
