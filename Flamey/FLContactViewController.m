//
//  FLContactViewController.m
//  Flamey
//
//  Created by Shane Rogers on 2/20/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLContactViewController.h"

#import <SIAlertView/SIAlertView.h>

NSString *const kEmailREPL = @"hi@repllabs.com";
NSString *const kREPLWebsiteName = @"repllabs.com";
NSString *const kREPLWebsiteURL = @"http://www.repllabs.com";

@interface FLContactViewController ()

@end

@implementation FLContactViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self formatEmailLabel];
    [self formatWebsiteLink];
}

- (void)viewDidLayoutSubviews {
    [self setHeaderLogo];

}

- (void)setHeaderLogo {
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    _navTitle.titleView = logoView;
}

- (void)formatEmailLabel {
    _contactEmailLabel.enabledTextCheckingTypes = UIDataDetectorTypeAll;
    _contactEmailLabel.delegate = self;
    _contactEmailLabel.text = kEmailREPL;
    NSRange range = [_contactEmailLabel.text rangeOfString:kEmailREPL];
    [_contactEmailLabel addLinkToURL:[NSURL URLWithString:kEmailREPL] withRange:range];
}

- (void)formatWebsiteLink {
    _websiteLink.enabledTextCheckingTypes = UIDataDetectorTypeAll;
    _websiteLink.delegate = self;
    _websiteLink.text = kREPLWebsiteName;
    NSRange range = [_websiteLink.text rangeOfString:kREPLWebsiteURL];
    [_websiteLink addLinkToURL:[NSURL URLWithString:kREPLWebsiteURL] withRange:range];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString isEqualToString:@"http://repllabs.com"]) {
       [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kREPLWebsiteURL]];
    } else {
        [self displayMailComposerSheet];
    }
}

- (IBAction)back:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)displayMailComposerSheet {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    picker.mailComposeDelegate = self;

    [picker setSubject:@"Hi"];

    // Set up recipients
    NSArray *toRecipients = [NSArray arrayWithObject:kEmailREPL];

    [picker setToRecipients:toRecipients];

    // Fill out the email body text
    NSString *emailBody = @"Thanks for getting in touch :) \n Let us know what you are thinking";
    [picker setMessageBody:emailBody isHTML:NO];

    [self presentViewController:picker animated:YES completion:NULL];
}

#pragma MailComposer
- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: Mail sending canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: Mail saved");
            break;
        case MFMailComposeResultSent:
            [self showAlertPrimary:@"Message Sent" secondary:@"We will get back to you soon" withError:NO];
            break;
        case MFMailComposeResultFailed:
            [self showAlertPrimary:@"Uh Oh!" secondary:@"There was an error" withError:YES];
            break;
        default:
            [self showAlertPrimary:@"Message not sent" secondary:@"" withError:NO];
            break;
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)showAlertPrimary:(NSString *)primary secondary:(NSString *)secondary withError:(BOOL)error {
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:primary andMessage:secondary];

    [alertView setTitleFont:[UIFont fontWithName:@"AvenirNext-Regular" size:20.0]];
    [alertView setMessageFont:[UIFont fontWithName:@"AvenirNext-Regular" size:14.0]];
    [alertView setButtonFont:[UIFont fontWithName:@"AvenirNext-Regular" size:16.0]];

    if (error) {
        [alertView addButtonWithTitle:@"Try Again!"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [self displayMailComposerSheet];
                              }];

        [alertView addButtonWithTitle:@"Try Later"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alert) {
                                  [self dismissViewControllerAnimated:YES completion:NULL];
                              }];
    } else {
        [alertView addButtonWithTitle:@"Great!"
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alert) {
                                  [self dismissViewControllerAnimated:YES completion:NULL];
                              }];
    }

    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;

    [alertView show];
}

/*
 #pragma mark - Navigation

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
