//
//  SecondViewController.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import "FLSettingsViewController.h"
#import "FLSettings.h"

#import "FLAnnotationStore.h"
#import "FLProcessedImagesStore.h"

#import "FLContactViewController.h"

@interface FLSettingsViewController ()

@property (nonatomic, strong) UITableView *settingsTable;
@property (nonatomic, strong) NSMutableArray *arrayOfSections;

@end

static NSString * const kSettingsCellIdentifier = @"cell";

static NSString * const kContactCell = @"Contact Us";
static NSString * const kContactViewController = @"ContactViewController";
static NSString * const kPrivacyCell = @"Privacy Policy";
static NSString * const kTOSCell = @"Terms of Service";
static NSString * const kLogoutCell = @"Logout";
static NSString * const kDeleteAccountCell = @"Delete Account";

@implementation FLSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self buildArrayOfSections];
    [self renderSettingsTable];
    [self setLogoAndVersion];
}

- (void)setLogoAndVersion {
    [_logoImageView setImage:[UIImage imageNamed:@"test_image"]];
    // TODO: Pull the specified app version from the app plist
    [_versionNumber setText:[NSString stringWithFormat:@"Version: %@", @"0.0.1"]];
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
    [_settingsTable setBackgroundColor:[UIColor grayColor]];
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
            label = [self newLabelWithTitle:@"Flamey Info"];
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

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"Selected section>> %d",indexPath.section);
    NSLog(@"Selected row of section >> %d",indexPath.row);

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *cellName = cell.textLabel.text;

    // Enum pattern would be better here

    if ([cellName isEqualToString:kContactCell]) {
        FLContactViewController *contactViewController = [[FLContactViewController alloc] initWithNibName:kContactViewController bundle:nil];

        [self.navigationController pushViewController:contactViewController animated:YES];
    } else if ([cellName isEqualToString:kPrivacyCell]) {
        NSLog(@"Cell name: %@", cellName);
    } else if ([cellName isEqualToString:kTOSCell]) {
        NSLog(@"Cell name: %@", cellName);
    } else if ([cellName isEqualToString:kLogoutCell]) {
        NSLog(@"Cell name: %@", cellName);
    } else if ([cellName isEqualToString:kDeleteAccountCell]) {
        NSLog(@"Cell name: %@", cellName);
    } else {
        NSLog(@"Warning: no cell found");
    }
}

- (void)logOut:(id)paramSender {
    [FBSession.activeSession closeAndClearTokenInformation];
    [FLSettings defaultSettings].shouldSkipLogin = NO;
    [FLSettings defaultSettings].needToLogin = YES;

    [[FLAnnotationStore sharedStore] flushStore];
    [[FLProcessedImagesStore sharedStore] flushStore];

    [self performSegueWithIdentifier:@"logOut" sender:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
