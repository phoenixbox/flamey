//
//  FBLLoginViewController.m
//  Stndout
//
//  Created by Shane Rogers on 4/12/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FBLLoginViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "AFNetworking.h"
#import "FBLAppConstants.h"
#import "FBLPushNotificationController.h"
#import "FBLHelpers.h"
#import "FBLViewHelpers.h"

@interface FBLLoginViewController ()

@end

@implementation FBLLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)facebookButton:(id)sender {
    // TODO: Insert pre-permissions here
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"email", @"user_friends"] block:^(PFUser *user, NSError *error)
     {
         if (user != nil)
         {
             if (user[PF_CUSTOMER_FACEBOOKID] == nil)
             {
                 [self requestFacebook:user];
             }
             else [self userLoggedIn:user];
         }
         else {
             SIAlertView *alert = [FBLViewHelpers createAlertForError:error withTitle:@"Facebook Login Error" andMessage:@"Something went wrong when we tried to talk to Facebook"];
             [alert show];
         }
     }];
}

- (void)requestFacebook:(PFUser *)user {
    FBRequest *request = [FBRequest requestForMe];
    [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error)
     {
         if (error == nil)
         {
             NSDictionary *userData = (NSDictionary *)result;
             [self processFacebook:user UserData:userData];
         }
         else
         {
             [PFUser logOut];
             SIAlertView *alert = [FBLViewHelpers createAlertForError:error withTitle:@"Couldn't get your Facebook info." andMessage:@"Something went wrong when we tried to talk to Facebook"];
             [alert show];
         }
     }];
}

- (void)processFacebook:(PFUser *)user UserData:(NSDictionary *)userData {
    NSString *link = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=large", userData[@"id"]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:link]];

    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFImageResponseSerializer serializer];

    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         UIImage *image = (UIImage *)responseObject;
         UIImage *picture = ResizeImage(image, 280, 280);
         UIImage *thumbnail = ResizeImage(image, 60, 60);

         PFFile *filePicture = [PFFile fileWithName:@"picture.jpg" data:UIImageJPEGRepresentation(picture, 0.6)];
         [filePicture saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) {
                  SIAlertView *alert = [FBLViewHelpers createAlertForError:error withTitle:@"UH OH!" andMessage:@"Something went wrong when we tried to get your profile picture"];
                  [alert show];
              };
          }];
         PFFile *fileThumbnail = [PFFile fileWithName:@"thumbnail.jpg" data:UIImageJPEGRepresentation(thumbnail, 0.6)];
         [fileThumbnail saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error != nil) {
                  SIAlertView *alert = [FBLViewHelpers createAlertForError:error withTitle:@"Couldnt save profile pic" andMessage:@"Something went wrong :("];
                  [alert show];
              }
          }];
         user[PF_CUSTOMER_EMAILCOPY] = userData[@"email"];
         user[PF_CUSTOMER_FULLNAME] = userData[@"name"];
         user[PF_CUSTOMER_FULLNAME_LOWER] = [userData[@"name"] lowercaseString];
         user[PF_CUSTOMER_FACEBOOKID] = userData[@"id"];
         user[PF_CUSTOMER_PICTURE] = filePicture;
         user[PF_CUSTOMER_THUMBNAIL] = fileThumbnail;
         [user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error)
          {
              if (error == nil)
              {
                  [self userLoggedIn:user];
              }
              else
              {
                  [PFUser logOut];
                  SIAlertView *alert = [FBLViewHelpers createAlertForError:error withTitle:@"Couldnt save info" andMessage:@"Something went wrong :("];
                  [alert show];
              }
          }];
     }
                                     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [PFUser logOut];
         SIAlertView *alert = [FBLViewHelpers createAlertForError:error withTitle:@"Couldn't get your Facebook info." andMessage:@"Failed to fetch Facebook profile picture."];
         [alert show];
     }];
    [[NSOperationQueue mainQueue] addOperation:operation];
}

- (void)userLoggedIn:(PFUser *)user {
    ParsePushUserAssign();
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
