//
//  FLFacebookAlbumTableViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/17/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookAlbumTableViewController.h"
#import "FLFacebookPhotoPickerViewController.h"

// Libs
#import <MBProgressHUD/MBProgressHUD.h>
#import <SIAlertView.h>
#import "Mixpanel.h"
#import "FLNotificationConstants.h"
#import "Reachability.h"

@interface FLFacebookAlbumTableViewController ()

@property (strong) NSMutableArray* datasource;
@property (strong) NSMutableArray* albumCoverArray;
@property (weak) id<FLPhotosCollectionViewController> delegate;
@property (nonatomic, strong) MBProgressHUD *hud;
@property (nonatomic, strong) NSArray* permissions;

@end

@implementation FLFacebookAlbumTableViewController


+(void)showWithDelegate:(id<FLPhotosCollectionViewController>)delegate
{
    // Not hit with the interface builder
    FLFacebookAlbumTableViewController* albumTableView = [[FLFacebookAlbumTableViewController alloc] initWithStyle:UITableViewStylePlain];
    UIViewController* top = [UIApplication sharedApplication].keyWindow.rootViewController;

    while (top.presentedViewController) {
        top = top.presentedViewController;
    }

    if (delegate) {
        albumTableView.delegate = delegate;
    }

    UINavigationController* navigationController = [[UINavigationController alloc] initWithRootViewController:albumTableView];

    // Solution
    navigationController.modalPresentationStyle = UIModalPresentationCurrentContext;
    navigationController.modalPresentationStyle = UIModalPresentationFormSheet;

    [top presentViewController:navigationController animated:YES completion:nil];
}

- (void)showNetworkErrorModal:(NSNotification *)notification {
    Reachability *reachability = (Reachability *)[notification object];

    if ([reachability isReachable]) {
        NSLog(@"Facebook connected");
    } else {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Uh Oh!" andMessage:@"Lost connection to Facebook!"];

        [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
        [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
        [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

        [alertView addButtonWithTitle:@"Try Again!"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [self sendRequests];
                              }];

        [alertView addButtonWithTitle:@"Try Later"
                                 type:SIAlertViewButtonTypeDestructive
                              handler:^(SIAlertView *alert) {
                                  [self doneSelectingPhotos];
                              }];

        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

        [alertView show];
    }
}

- (void)doneSelectingPhotos {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)setActivityScreen {
    _hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [self.view bringSubviewToFront:_hud];
    [_hud setLabelFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [_hud setCenter:self.view.center];
    _hud.mode = MBProgressHUDModeIndeterminate;
    _hud.labelText = @"Loading";
}

- (void)styleTableEmptyContent {
    [_albumTable setBackgroundColor:[UIColor whiteColor]];
    _albumTable.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 10.0f)];
    [_albumTable.tableFooterView setBackgroundColor:[UIColor whiteColor]];
}

- (void)setHeaderLogo {
    [[self navigationItem] setTitleView:nil];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    self.navigationItem.titleView = logoView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self styleTableEmptyContent];
    [self setActivityScreen];
    [self setHeaderLogo];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelectingPhotos)];

    _permissions = [NSArray arrayWithObjects:@"user_friends", @"user_photos", nil];
    BOOL hasPermissions = YES;
    for (NSString *permission in _permissions) {
        hasPermissions = (hasPermissions && [FBSession.activeSession hasGranted:permission]);
    }
    if (FBSession.activeSession.isOpen && hasPermissions) {
        [self sendRequests];
    } else {
        [self askFacebookPermission];
    }

    _datasource = [[NSMutableArray alloc] init];

    [self listenToNetworkReachability];
}

- (void)listenToNetworkReachability {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showNetworkErrorModal:)
                                                 name:kReachabilityChangedNotification
                                               object:nil];
}

- (void)askFacebookPermission {
    [FBSession openActiveSessionWithReadPermissions:_permissions
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session,
                                                      FBSessionState status,
                                                      NSError *error) {
                                      // if login fails for any reason, we alert
                                      if (error) {
                                          [self showAlert:error withSelectorName:@"askFacebookPermission"];
                                          // if otherwise we check to see if the session is open, an alternative to
                                          // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
                                          // property of the session object; the macros are useful, however, for more
                                          // detailed state checking for FBSession objects
                                      } else if (FB_ISSESSIONOPENWITHSTATE(status)) {
                                          // send our requests if we successfully logged in
                                          [self sendRequests];
                                      }
                                  }];
}

- (void)sendRequests {
    // Retrieve the users photo album data
    [_hud show:YES];

    NSString* graphPath = @"/me/albums";
    [FBRequestConnection startWithGraphPath:graphPath
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result, NSError *error) {

                              if (error != nil) {
                                  NSLog(@"ERROR TOWN");
                                  [self showAlert:error withSelectorName:@"sendRequests"];
                              } else {
                                  NSDictionary* resultDict = (NSDictionary*)result;
                                  _datasource = [NSMutableArray arrayWithArray:[resultDict objectForKey:@"data"]];
                                  _albumCoverArray = [[NSMutableArray alloc] initWithCapacity:_datasource.count];

                                  __block int count = 0;

                                  // Get art for albums
                                  for (int i = 0 ; i < _datasource.count; i++) {
                                      NSString* graphPath = [NSString stringWithFormat:@"/%@/picture", [[_datasource objectAtIndex:i] objectForKey:@"id"]];
                                      NSDictionary* params = [NSDictionary dictionaryWithObjectsAndKeys:@"album", @"type", nil];

                                      [FBRequestConnection startWithGraphPath:graphPath
                                                                   parameters:params
                                                                   HTTPMethod:@"GET"
                                                            completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                count++;

                                                                NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:i], @"index" , connection.urlResponse.URL, @"URL", nil];

                                                                [_albumCoverArray addObject:dict];


                                                                if (count ==_datasource.count) {
                                                                    [FBRequestConnection startWithGraphPath:@"/me/photos"
                                                                                                 parameters:nil
                                                                                                 HTTPMethod:@"GET"
                                                                                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                                              NSDictionary* resultDict = (NSDictionary*)result;

                                                                                              [_hud hide:YES];

                                                                                              if (!error) {
                                                                                                  NSDictionary *singlePhotoObject = [resultDict objectForKey:@"data"][0];
                                                                                                  NSDictionary *singlePhoto = [singlePhotoObject objectForKey:@"images"][0];

                                                                                                  NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:count], @"index" , [singlePhoto objectForKey:@"source"], @"URL", nil];
                                                                                                  [_albumCoverArray insertObject:dict atIndex:0];
                                                                                                  
                                                                                                  [self.tableView reloadData];
                                                                                              } else {
                                                                                                  [self showAlert:error withSelectorName:@"sendRequests"];
                                                                                              }
                                                                                          }];
                                                                }
                                                            }];
                                  }
                              }

                          }];

}

- (void)showAlert:(NSError *)error withSelectorName:(NSString *)selectorName {
    SEL selector = NSSelectorFromString(selectorName);
    IMP imp = [self methodForSelector:selector];
    void (*func)(id, SEL) = (void *)imp;

    NSLog(@"Error when fetching album data from Facebook: %@", error);

    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Uh Oh Facebook!" andMessage:@"Something went wrong when we tried to talk to Facebook"];

    [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

    [alertView addButtonWithTitle:@"Try Again"
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alert) {
                              func(self, selector);
                          }];

    [alertView addButtonWithTitle:@"Try Later"
                             type:SIAlertViewButtonTypeDestructive
                          handler:^(SIAlertView *alert) {
                              [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
                          }];

    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
    
    [alertView show];
}

#pragma mark - UITableView Datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _albumCoverArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }

    cell.textLabel.text = @"Photos of Me";
    @try {
        cell.textLabel.text = [[_datasource objectAtIndex:indexPath.row] objectForKey:@"name"];
    }
    @catch (NSException *exception) {

    }
    @finally {
    }

    [cell.textLabel setFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    FLFacebookPhotoPickerViewController* vc = [[FLFacebookPhotoPickerViewController alloc] init];

    @try {
        vc.albumId = [[_datasource objectAtIndex:indexPath.row] objectForKey:@"id"];
        vc.title = [[_datasource objectAtIndex:indexPath.row] objectForKey:@"name"];
    }
    @catch (NSException *exception) {
        vc.albumId = false;
        vc.title = @"Photos of me";
    }
    @finally {
    }

    [self.navigationController pushViewController:vc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)prepareForUnwind:(UIStoryboardSegue *)segue {
    NSLog(@"Required for an unwinding segue");
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
