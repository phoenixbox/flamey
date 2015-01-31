//
//  FLFacebookPhotoCollectionViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/17/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookPhotoPickerViewController.h"

#import <FacebookSDK/FacebookSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "FLPhotoCollectionViewCell.h"

#import "FLFacebookPhotoCollectionViewCell.h"

#import "FLPhotoStore.h"
#import "FLPhoto.h"

@interface FLFacebookPhotoPickerViewController ()

@property (strong) NSMutableArray* datasource;
@property (strong) UICollectionView* collectionView;
@property (nonatomic, assign) CGFloat cellSize;

@end

@implementation FLFacebookPhotoPickerViewController

static NSString * const kCollectionViewCellIdentifier = @"FLFacebookPhotoCollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];

    _datasource = [[NSMutableArray alloc] init];

    [self buildPhotoCollection];
    [self sendRequest];
}

- (void)buildPhotoCollection {
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[self buildCollectionViewCellLayout]];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([FLFacebookPhotoCollectionViewCell class])
                                bundle:[NSBundle mainBundle]];
    [_collectionView registerNib:nib forCellWithReuseIdentifier:kCollectionViewCellIdentifier];

    _collectionView.backgroundColor = [UIColor whiteColor];
    // Custom cell here identifier here
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];

    [self.view addSubview:_collectionView];
}

- (UICollectionViewFlowLayout *)buildCollectionViewCellLayout {
    UICollectionViewFlowLayout *flowLayout = [UICollectionViewFlowLayout new];
    flowLayout.minimumLineSpacing = 2.5f;
    flowLayout.minimumInteritemSpacing = 2.0f;
    self.cellSize = (self.view.frame.size.width - 10)/3;
    flowLayout.itemSize = CGSizeMake(self.cellSize,self.cellSize);
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.sectionInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f);

    return flowLayout;
}

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
    FLFacebookPhotoCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kCollectionViewCellIdentifier
                                                                                        forIndexPath:indexPath];
    NSString *remoteURL = [_datasource[indexPath.row] objectForKey:@"URL"];
    cell.imageViewBackgroundImage.contentMode = UIViewContentModeScaleAspectFit;
    [cell.imageViewBackgroundImage sd_setImageWithURL:[NSURL URLWithString:remoteURL] placeholderImage:nil];

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%ld", (long)[indexPath row]);
    NSDictionary *selectedPhoto = _datasource[indexPath.row];

    FLPhoto *photo = [[FLPhoto alloc] initWithDictionary:selectedPhoto error:nil];
    [[FLPhotoStore sharedStore] addUniquePhoto:photo];

//    [self.collectionView reloadItemsAtIndexPaths:[self.collectionView indexPathsForVisibleItems]];
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
