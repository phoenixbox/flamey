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

// Data layer
#import "FLPhotoStore.h"

NSString *const kPhotoCellIdentifier = @"FLPhotoCollectionViewCell";

@interface FLPhotosCollectionViewController ()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIScrollView *_scrollView;
@property (strong, nonatomic) IBOutlet UINavigationBar *navBar;

@end

@implementation FLPhotosCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.translucent = NO;
//    [self addNavigationItems];
    [self renderScrollView];
    [self resetScrollContentSize];
    [self buildPhotoCollection];
}

//- (void)addNavigationItems {
//    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"Add" style:UIBarButtonItemStylePlain target:self action:@selector(showAlbumPicker:)];
//    NSDictionary* barButtonItemAttributes = @{NSFontAttributeName:[UIFont fontWithName:@"Georgia" size:20.0f],
//                                              NSForegroundColorAttributeName:[UIColor colorWithRed:141.0/255.0 green:209.0/255.0 blue:205.0/255.0 alpha:1.0]
//      };
//
//    [barButton setTitleTextAttributes:barButtonItemAttributes forState:UIControlStateNormal];
//    barButton.title = @"Add";
//    [_navBar setRightBarButtonItems:@[]];
//    [self.navigationController.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
//}

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
    _collectionView = [[UICollectionView alloc]initWithFrame:viewFrame collectionViewLayout:[CollectionViewHelpers buildLayoutWithWidth:viewFrame.size.width]];

    [_collectionView registerClass:[FLPhotoCollectionViewCell class] forCellWithReuseIdentifier:kPhotoCellIdentifier];
    [_collectionView setBackgroundColor:[UIColor whiteColor]];

    // Custom cell here identifier here
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];

    [self._scrollView addSubview:_collectionView];

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

    [cell.editButton setTitle:@"EDIT" forState:UIControlStateNormal];
    [cell setBackgroundColor:[UIColor blueColor]];

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected cell %lu", (long)[indexPath row]);

    // Trigger image editor
}


#pragma RFFacebookProtocol

-(void)faceBookViewController:(id)controller didSelectPhoto:(UIImage *)image
{
    NSLog(@"Callback");
}

- (void)removeEmptyCollectionMessage {
    [_collectionView.backgroundView removeFromSuperview];
}

- (void)renderEmptyMessage {
    [CollectionViewHelpers renderEmptyMessage:@"Tap \"Add\" to select some of your Facebook photos to edit" forCollectionView:_collectionView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showAlbums:(id)sender {
    [FLFacebookAlbumTableViewController showWithDelegate:self];
}
@end
