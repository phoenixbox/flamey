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

    [self configureCollectionView];
    [self sendRequest];
}

- (void)configureCollectionView {
    CGFloat const inset = 5.0;
    CGFloat const eachLineCount = 4.0;
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumInteritemSpacing = inset;
    flowLayout.minimumLineSpacing = inset;
    flowLayout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset);
    CGFloat width = (CGRectGetWidth(self.view.bounds)-(eachLineCount+1)*inset)/eachLineCount;
    flowLayout.itemSize = CGSizeMake(width, width);

    _collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    _collectionView.delegate = self;
    _collectionView.dataSource = self;
    _collectionView.alwaysBounceVertical = YES;
    _collectionView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    _collectionView.backgroundColor = [UIColor whiteColor];
    [_collectionView registerClass:[FLFacebookPhotoCollectionViewCell class] forCellWithReuseIdentifier:cellIdentifier];
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendRequest {
    if(_albumId){
        NSString* graphPath = [NSString stringWithFormat:@"/%@?fields=photos", _albumId];

        [FBRequestConnection startWithGraphPath:graphPath parameters:nil HTTPMethod:@"GET" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            NSDictionary* resultDict = (NSDictionary*)result;

            NSDictionary* dict  = [resultDict objectForKey:@"photos"];
            NSArray* array = [dict objectForKey:@"data"];
            for (NSDictionary* innerDict in array) {
                NSString* source = [innerDict objectForKey:@"source"];
                [_datasource addObject:source];
            }
            [_collectionView reloadData];
        }];
    } else {
        // If fetching straight up data

        [FBRequestConnection startWithGraphPath:@"/me/photos"
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  NSDictionary* resultDict = (NSDictionary*)result;
                                  NSArray* array = [resultDict objectForKey:@"data"];
                                  for (NSDictionary* innerDict in array) {
                                      NSString* source = [innerDict objectForKey:@"source"];
                                      [_datasource addObject:source];
                                  }
                                  [_collectionView reloadData];
                                  
                                  
                              }];
        
    }
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
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifier forIndexPath:indexPath];

    UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, cell.contentView.frame.size.width, cell.contentView.frame.size.height)];
    imageView.tag = 100;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    [cell.contentView addSubview:imageView];

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSData* imgData = [NSData dataWithContentsOfURL:[NSURL URLWithString:_datasource[indexPath.row]]];
        UIImage* img = [UIImage imageWithData:imgData];
        dispatch_async(dispatch_get_main_queue(), ^{
            [imageView setImage:img];
        });
    });

    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Selected collection image");
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
