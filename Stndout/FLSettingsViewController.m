//
//  SecondViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLSettingsViewController.h"

// Data Layer
#import "FLSettings.h"
#import "FLAnnotationStore.h"
#import "FLProcessedImagesStore.h"

// Components
#import "FLContactViewController.h"
#import "FLTOSViewController.h"
#import "FLPrivacyViewController.h"

// Pods
#import "Mixpanel.h"

// Helpers
#import "FLViewHelpers.h"

@interface FLSettingsViewController ()

@property (nonatomic, strong) UITableView *settingsTable;
@property (nonatomic, strong) NSMutableArray *arrayOfSections;

@end

static NSString * const kSettingsCellIdentifier = @"cell";

static NSString * const kContactCell = @"Contact Us";
static NSString * const kContactViewController = @"FLContactViewController";
static NSString * const kPrivacyCell = @"Privacy Policy";
static NSString * const kPrivacyViewController = @"FLPrivacyViewController";
static NSString * const kTOSCell = @"Terms of Service";
static NSString * const kTOSViewController = @"FLTOSViewController";
static NSString * const kLogoutCell = @"Logout";
static NSString * const kDeleteAccountCell = @"Delete Account";
static NSString * const kConfirmDeleteAccount = @"Yes";
static NSString * const kCancelDeleteAccount = @"Not right now";
static NSString * const kDeleteAccountActionTitle = @"Delete your account?";

@implementation FLSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    // Track settings loaded
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Navigation" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"loaded"
                                               }];
    [self setHeaderLogo];
    [self buildArrayOfSections];
    [self renderSettingsTable];
    [self setLogoAndVersion];
}

- (void)setHeaderLogo {
    [[self navigationItem] setTitleView:nil];
    UIImageView *logoView = [[UIImageView alloc]initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    UIImage *logoImage = [UIImage imageNamed:@"newTitlebar.png"];
    [logoView setImage:logoImage];
    self.navigationItem.titleView = logoView;
}

- (void)setLogoAndVersion {
    [_logoImageView setImage:[UIImage imageNamed:@"LogoLong"]];
    // TODO: Pull the specified app version from the app plist
    NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"];
    [_versionNumber setText:[NSString stringWithFormat:@"Version: %@", appVersion]];
    _versionNumber.font = [UIFont fontWithName:@"AvenirNext-Regular" size:10.0f];
    [_versionNumber sizeToFit];
}

- (void)renderSettingsTable {
    _settingsTable = [[UITableView alloc] initWithFrame:_tableContainer.bounds style:UITableViewStyleGrouped];
    [_tableContainer addSubview:_settingsTable];
// Need to set a default cell class??
    [_settingsTable registerClass:[UITableViewCell class] forCellReuseIdentifier:kSettingsCellIdentifier];
    _settingsTable.delegate = self;
    _settingsTable.dataSource = self;
    _settingsTable.alwaysBounceVertical = NO;
    _settingsTable.scrollEnabled = NO;
    [_settingsTable setBackgroundColor:[UIColor whiteColor]];
    _settingsTable.autoresizingMask = UIViewAutoresizingFlexibleWidth |
    UIViewAutoresizingFlexibleHeight;

    _settingsTable.showsVerticalScrollIndicator = NO;
    [_settingsTable setSeparatorColor:[UIColor blackColor]];
}

/* 
When more options are required then we can add the logo and version num to the
final sections footer view
*/
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *headerView;
    UILabel *label;

    switch (section) {
          case 0:
            label = [self newLabelWithTitle:@"Personal Info"];
            break;
          case 1:
            label = [self newLabelWithTitle:@"Stndout Info"];
            break;
          case 2:
            label = [self newLabelWithTitle:@"Account Actions"];
            break;
          default:
            NSLog(@"WARNING: No section index matched");
            break;
    }

    label.frame = CGRectMake(label.frame.origin.x + 10.0f,
                             5.0f, /* Go 5 points down in y axis */
                             label.frame.size.width,
                             label.frame.size.height);

    CGRect resultFrame = CGRectMake(0.0f,
                                    0.0f,
                                    label.frame.size.width + 10.0f,
                                    label.frame.size.height);
    headerView = [[UIView alloc] initWithFrame:resultFrame];
    [headerView setBackgroundColor:[UIColor lightGrayColor]];
    [headerView addSubview:label];

    return headerView;
}

- (CGFloat) tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}

- (UILabel *)newLabelWithTitle:(NSString *)paramTitle {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = paramTitle;
    label.backgroundColor = [UIColor clearColor];
    float copySize = [FLViewHelpers bodyCopyForScreenSize];
    label.font = [UIFont fontWithName:@"AvenirNext-Regular" size:copySize];
    [label sizeToFit];

    return label;
}

// Change the interface to accept an array of cell names
- (NSMutableArray *)newSectionWithCellNames:(NSArray *)cellNames {
    NSMutableArray *result = [[NSMutableArray alloc] init];

    NSUInteger i = 0;

    for (i = 0;i < [cellNames count]; i++) {
        [result addObject:[cellNames objectAtIndex:i]];
    }

    return result;
}

- (NSMutableArray *)buildArrayOfSections {
    NSMutableArray *personalSection = [self newSectionWithCellNames:@[@"Number of uploads: "]];
    NSMutableArray *tosSection = [self newSectionWithCellNames:@[kContactCell, kPrivacyCell, kTOSCell]];
    NSMutableArray *actionSection = [self newSectionWithCellNames:@[kLogoutCell, kDeleteAccountCell]];

    // TODO: Double check this setting
    _arrayOfSections = (NSMutableArray *)@[personalSection, tosSection, actionSection];

    return _arrayOfSections;
}

#pragma UITableViewDelgate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    NSLog(@"numberOfSectionsInTableView: %lu", (unsigned long)_arrayOfSections.count);
    return _arrayOfSections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSMutableArray *settingsSection = _arrayOfSections[section];

    NSLog(@"numberOfRowsInSection: %lu", (unsigned long)settingsSection.count);
    return settingsSection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:kSettingsCellIdentifier
                                           forIndexPath:indexPath];
    NSMutableArray *sectionArray = self.arrayOfSections[indexPath.section];

    cell.textLabel.text = sectionArray[indexPath.row];
    float copySize = [FLViewHelpers bodyCopyForScreenSize];
    cell.textLabel.font = [UIFont fontWithName:@"AvenirNext-Regular" size:copySize];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellName = cell.textLabel.text;

    // Track pages loaded
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    // Enum pattern would be better here
    if ([cellName isEqualToString:kContactCell]) {
        FLContactViewController *contactViewController = [[FLContactViewController alloc] initWithNibName:kContactViewController bundle:nil];
        [self presentViewController:contactViewController animated:YES completion:nil];
    } else if ([cellName isEqualToString:kPrivacyCell]) {
        FLPrivacyViewController *privacyViewController = [[FLPrivacyViewController alloc] initWithNibName:kPrivacyViewController bundle:nil];
        [self presentViewController:privacyViewController animated:YES completion:nil];
    } else if ([cellName isEqualToString:kTOSCell]) {
        FLTOSViewController *TOSViewController = [[FLTOSViewController alloc] initWithNibName:kTOSViewController bundle:nil];
        [self presentViewController:TOSViewController animated:YES completion:nil];
    } else if ([cellName isEqualToString:kLogoutCell]) {
        [self logOut];
    } else if ([cellName isEqualToString:kDeleteAccountCell]) {
        [self presentAccountDeleteOptions];
    } else {
        NSLog(@"Warning: no cell found");
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.frame.size.width, 10.0f)];
    [footer setBackgroundColor:[UIColor whiteColor]];

    return footer;
}

- (void)flushStoresAndSessions {
    [FBSession.activeSession closeAndClearTokenInformation];
    FLSettings *settings = [FLSettings defaultSettings];
    [settings setSession:nil];
    [settings setUser:nil];
    [[FLAnnotationStore sharedStore] flushStore];
    [[FLProcessedImagesStore sharedStore] flushStore];
}

- (void)logOut {
    [self flushStoresAndSessions];
    
    void(^completionBlock)(void)=^(void) {
        Mixpanel *mixpanel = [Mixpanel sharedInstance];
        [mixpanel track:@"Logout" properties:@{
                                                @"controller": NSStringFromClass([self class]),
                                                @"state": @"default",
                                                @"result": @"success",
                                                }];
        [self performSegueWithIdentifier:@"logOut" sender:self];
    };

    [self dismissViewControllerAnimated:YES completion:completionBlock];
}

- (void)presentAccountDeleteOptions {
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:kDeleteAccountActionTitle
                                  delegate:self
                                  cancelButtonTitle:kCancelDeleteAccount
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:kConfirmDeleteAccount, nil];

    [actionSheet showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    // Track account deletions
    Mixpanel *mixpanel = [Mixpanel sharedInstance];

    NSString *buttonTitle = [actionSheet buttonTitleAtIndex:buttonIndex];

    if  ([buttonTitle isEqualToString:kConfirmDeleteAccount]) {
        [mixpanel track:@"DeleteAccount" properties:@{
                                               @"controller": NSStringFromClass([self class]),
                                               @"state": @"default",
                                               @"result": @"success",
                                               }];
        // TODO: Delete server side account
        [self logOut];
    }
    if ([buttonTitle isEqualToString:kCancelDeleteAccount]) {
        [mixpanel track:@"DeleteAccount" properties:@{
                                                      @"controller": NSStringFromClass([self class]),
                                                      @"state": @"default",
                                                      @"result": @"failure",
                                                      }];
        [actionSheet dismissWithClickedButtonIndex:[actionSheet cancelButtonIndex] animated:YES];
        actionSheet = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end