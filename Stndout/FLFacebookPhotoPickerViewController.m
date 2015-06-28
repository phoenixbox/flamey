//
//  FLFacebookPhotoCollectionViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/17/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookPhotoPickerViewController.h"

// Libs
#import <MBProgressHUD/MBProgressHUD.h>
#import <FacebookSDK/FacebookSDK.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <SIAlertView.h>
#import "Mixpanel.h"

// Components
#import "FLFacebookPhotoCollectionViewCell.h"

// DataLayer
#import "FLSelectedPhotoStore.h"
#import "FLPhoto.h"

// Helpers
#import "CollectionViewHelpers.h"

@interface FLFacebookPhotoPickerViewController ()

@property (strong) NSMutableArray* datasource;
@property (strong) UICollectionView* collectionView;
@property (nonatomic, assign) CGFloat cellSize;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) UITapGestureRecognizer *cellTap;

@end

@implementation FLFacebookPhotoPickerViewController

static NSString * const kCollectionViewCellIdentifier = @"FLFacebookPhotoCollectionViewCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateTitleStyle];

    _datasource = [[NSMutableArray alloc] init];

    [self buildPhotoCollection];
    [self sendRequest];

    // Track the user loading this page
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"loaded"
                                               }];
}

- (void)updateTitleStyle {
    NSString *title = self.navigationItem.title;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:18.0];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    self.navigationItem.titleView = label;
    label.text = title;
    [label sizeToFit];
}

- (void)buildPhotoCollection {
    // Initialize the colletion to the required frame with its delegates
    _collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:[CollectionViewHelpers buildLayoutWithWidth:self.view.frame.size.width]];
    [_collectionView setDelegate:self];
    [_collectionView setDataSource:self];
    [_collectionView setAllowsMultipleSelection:YES];

    // Fetch the nib by the class name
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([FLFacebookPhotoCollectionViewCell class])
                                bundle:[NSBundle mainBundle]];
    // Register the nib
    [_collectionView registerNib:nib forCellWithReuseIdentifier:kCollectionViewCellIdentifier];

    _collectionView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_collectionView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendRequest {
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [_hud setCenter:self.view.center];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = @"Loading";

    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    // TODO: Update to a less brittle interface
    [_hud show:YES];
    if(_albumId){
        NSString* graphPath = [NSString stringWithFormat:@"/%@?fields=photos", _albumId];

        [FBRequestConnection startWithGraphPath:graphPath
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  [_hud hide:YES];

                                  if (error) {
                                      [mixpanel track:@"PhotosFetch" properties:@{
                                                                                  @"controller": NSStringFromClass([self class]),
                                                                                  @"result": @"failure",
                                                                                  @"state": @"default",
                                                                                  @"error'": error.localizedFailureReason
                                                                                  }];
                                      [self showAlert:error withSelectorName:@"sendRequest"];
                                  } else {
                                      NSDictionary* resultDict = (NSDictionary*)result;
                                      NSDictionary* dict  = [resultDict objectForKey:@"photos"];
                                      NSArray* array = [dict objectForKey:@"data"];
                                      // Can events be tracked with property schemas that dont match
                                      [mixpanel track:@"PhotosFetch" properties:@{
                                                                                  @"controller": NSStringFromClass([self class]),
                                                                                  @"state": @"default",
                                                                                  @"result": @"success"
                                                                                  }];
                                      [self addImagesToDataSource:array];
                                  }
        }];
    } else {
        [FBRequestConnection startWithGraphPath:@"/me/photos"
                                     parameters:nil
                                     HTTPMethod:@"GET"
                              completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                  [_hud hide:YES];
                                  
                                  if (error) {
                                      [self showAlert:error withSelectorName:@"sendRequest"];
                                      [mixpanel track:@"PhotosFetch" properties:@{
                                                                                  @"controller": NSStringFromClass([self class]),
                                                                                  @"result": @"failure",
                                                                                  @"state": @"default",
                                                                                  @"error'": error.localizedFailureReason
                                                                                  }];
                                  } else {
                                      NSDictionary* resultDict = (NSDictionary*)result;
                                      NSArray* array = [resultDict objectForKey:@"data"];
                                      [self addImagesToDataSource:array];
                                      [mixpanel track:@"PhotosFetch" properties:@{
                                                                                  @"controller": NSStringFromClass([self class]),
                                                                                  @"state": @"default",
                                                                                  @"result": @"success"
                                                                                  }];
                                  }
                              }];
    }
}

- (void)showAlert:(NSError *)error withSelectorName:(NSString *)selectorName {
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    SEL selector = NSSelectorFromString(selectorName);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Uh Oh Facebook!" andMessage:@"Something went wrong when we tried to talk to Facebook"];

    [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

    [alertView addButtonWithTitle:@"Try Again"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              [mixpanel track:@"PhotosFetch" properties:@{
                                                                  @"controller": NSStringFromClass([self class]),
                                                                  @"state": @"retry",
                                                                  @"result": @"confirmed",
                                                                  }];
                              func(self, selector);
                          }];

    [alertView addButtonWithTitle:@"Try Later"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              Mixpanel *mixpanel = [Mixpanel sharedInstance];
                              [mixpanel track:@"PhotosFetch" properties:@{
                                                                          @"controller": NSStringFromClass([self class]),
                                                                          @"state": @"retry",
                                                                          @"result": @"rejected",
                                                                          }];
                          }];

    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

    [alertView show];
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
    cell.imageViewBackgroundImage.contentMode = UIViewContentModeScaleAspectFill;
    [cell.imageViewBackgroundImage sd_setImageWithURL:[NSURL URLWithString:remoteURL] placeholderImage:[UIImage imageNamed:@"Persona"]];

    // Has that photo been added to the store already
    NSString *facebookId = [_datasource[indexPath.row] objectForKey:@"id"];
    if ([[FLSelectedPhotoStore sharedStore] isPhotoPresent:facebookId]) {
        [cell setSelected:YES];

        _cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                action:@selector(handleTap:)];
        _cellTap.numberOfTouchesRequired = 1;
        _cellTap.numberOfTapsRequired = 1;

        [cell addGestureRecognizer:_cellTap];
        cell.userInteractionEnabled = YES;

    }

    return cell;
}

- (void)handleTap:(UIGestureRecognizer *)sender  {
    // use and remove
    FLFacebookPhotoCollectionViewCell *targetCell = (FLFacebookPhotoCollectionViewCell *)sender.view;

    NSIndexPath *indexPath = [_collectionView indexPathForCell:targetCell];

    NSDictionary *selectedPhoto = _datasource[indexPath.row];
    [[FLSelectedPhotoStore sharedStore] removePhotoById:[selectedPhoto objectForKey:@"id"]];

    [targetCell setSelected:NO];
    [targetCell removeGestureRecognizer:sender];
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    FLFacebookPhotoCollectionViewCell *cell = (FLFacebookPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    [cell setSelected:YES];
    NSDictionary *selectedPhoto = _datasource[indexPath.row];

    FLPhoto *photo = [[FLPhoto alloc] initWithDictionary:selectedPhoto error:nil];

    [[FLSelectedPhotoStore sharedStore] addUniquePhoto:photo];
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    FLFacebookPhotoCollectionViewCell *cell = (FLFacebookPhotoCollectionViewCell *)[collectionView cellForItemAtIndexPath:indexPath];

    NSDictionary *selectedPhoto = _datasource[indexPath.row];
    [[FLSelectedPhotoStore sharedStore] removePhotoById:[selectedPhoto objectForKey:@"id"]];

    [cell setSelected:NO];
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
