//
//  FLFacebookAlbumTableViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/17/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLFacebookAlbumTableViewController.h"
#import "FLFacebookPhotoPickerViewController.h"

@interface FLFacebookAlbumTableViewController ()

@property (strong) NSMutableArray* datasource;
@property (strong) NSMutableArray* albumCoverArray;
@property (weak) id<FLPhotosCollectionViewController> delegate;

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
    [top presentViewController:navigationController animated:YES completion:nil];
}

- (void)doneSelectingPhotos:(id)paramSender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneSelectingPhotos:)];

    self.title = @"Albums";
    NSArray* permissions = [NSArray arrayWithObjects:@"user_friends", @"user_photos", nil];
    BOOL hasPermissions = YES;
    for (NSString *permission in permissions) {
        hasPermissions = (hasPermissions && [FBSession.activeSession hasGranted:permission]);
    }
    if (FBSession.activeSession.isOpen && hasPermissions) {
        // login is integrated with the send button -- so if open, we send
        [self sendRequests];
    } else {
        [FBSession openActiveSessionWithReadPermissions:permissions
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState status,
                                                          NSError *error) {
                                          // if login fails for any reason, we alert
                                          if (error) {
                                              NSLog(@"%@", error.localizedDescription);
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could not connect to Facebook."
                                                                                              message:@"Please try again."
                                                                                             delegate:self
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                              [alert show];
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



    _datasource = [[NSMutableArray alloc] init];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)sendRequests {
    // Retrieve the users photo album data
    NSString* graphPath = @"/me/albums";
    [FBRequestConnection startWithGraphPath:graphPath
                                 parameters:nil
                                 HTTPMethod:@"GET"
                          completionHandler:^(FBRequestConnection *connection,
                                              id result, NSError *error) {

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
                                                                                          NSDictionary *singlePhotoObject = [resultDict objectForKey:@"data"][0];
                                                                                          NSDictionary *singlePhoto = [singlePhotoObject objectForKey:@"images"][0];
                                                                                          
                                                                                          NSDictionary* dict = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:count], @"index" , [singlePhoto objectForKey:@"source"], @"URL", nil];
                                                                                          [_albumCoverArray insertObject:dict atIndex:0];
                                                                                          [self.tableView reloadData];
                                                                                      }];
                                                            }
                                                        }];
                              }
                          }];

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
    
//    vc.delegate = _delegate;
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
