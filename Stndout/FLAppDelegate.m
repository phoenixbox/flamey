//
//  AppDelegate.m
//  Flamey
//
//  Created by Shane Rogers on 1/3/15.
//  Copyright (c) 2015 REPL. All rights reserved.
//

#import <FacebookSDK/FacebookSDK.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
//#import <ParseUI/ParseUI.h>

#import "FLAppDelegate.h"
#import "FLErrorHandler.h"
#import "BlurryModalSegue.h"

// Libs
#import "Reachability.h"

// Crashlytics
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

// FeedbackLoop
#import <FeedbackLoop/FeedbackLoop.h>

// Event Tracking
#import "Mixpanel.h"

#define MIXPANEL_TOKEN @""

@interface FLAppDelegate ()

@end

@implementation FLAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
//    [self logFonts];

//  Mixpanel
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
//  Crashlytics Kit
    [Fabric with:@[CrashlyticsKit]];

//  Parse setup ----------------------------------------------------------
    [Parse setApplicationId:@""
                  clientKey:@""];

    [PFFacebookUtils initializeFacebook];
    // TODO: update to the Stndout app token
    [FeedbackLoop initWithAppId:@""];

    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];

    [[BlurryModalSegue appearance] setBackingImageBlurRadius:@(20)];
    [[BlurryModalSegue appearance] setBackingImageSaturationDeltaFactor:@(.45)];

    [[UINavigationBar appearance] setBarTintColor:[UIColor whiteColor]];
    [self setNavBarStyles];
//    [self logFonts];

    // Initialize Reachability
    Reachability *reachability = [Reachability reachabilityWithHostname:@"www.facebook.com"];

    // Start Monitoring
    [reachability startNotifier];

    return YES;
}

- (void)setNavBarStyles {
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowOffset = CGSizeMake(0.0, 1.0);
    shadow.shadowColor = [UIColor whiteColor];

    // TODO Nav Bar font needs to be set by screen size
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil]
     setTitleTextAttributes:
     @{NSForegroundColorAttributeName:[UIColor blackColor],
       NSShadowAttributeName:shadow,
       NSFontAttributeName:[UIFont fontWithName:@"AvenirNext-Regular" size:18.0]
       }
     forState:UIControlStateNormal];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication fallbackHandler:^(FBAppCall *call) {
        // Since Scrumptious supports Single Sign On from the Facebook App (such as bookmarks),
        // we supply a fallback handler to parse any inbound URLs (e.g., deep links)
        // which can contain an access token.

        // TODO: What to take here??
//        Mixpanel *mixpanel = [Mixpanel sharedInstance];

        if (call.accessTokenData) {
            if ([FBSession activeSession].isOpen) {
                NSLog(@"INFO: Ignoring new access token because current session is open.");
            }
            else {
                [self _handleOpenURLWithAccessToken:call.accessTokenData];
            }
        }
    }];
}
- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"didFailToRegisterForRemoteNotificationsWithError %@", error.localizedDescription);
};

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"didReceiveLocalNotification");
};

#pragma mark - Helper Methods

- (void)_handleOpenURLWithAccessToken:(FBAccessTokenData *)token {
    // Initialize a new blank session instance...
    FBSession *sessionFromToken = [[FBSession alloc] initWithAppID:nil
                                                       permissions:nil
                                                   defaultAudience:FBSessionDefaultAudienceNone
                                                   urlSchemeSuffix:nil
                                                tokenCacheStrategy:[FBSessionTokenCachingStrategy nullCacheInstance]];
    [FBSession setActiveSession:sessionFromToken];
    // ... and open it from the supplied token.
    [sessionFromToken openFromAccessTokenData:token
                            completionHandler:^(FBSession *session, FBSessionState status, NSError *error) {
                                // Forward any errors to the FBLoginView delegate.
                                Mixpanel *mixpanel = [Mixpanel sharedInstance];

                                if (error) {
                                    FLErrorHandler(error);
                                }
                            }];
}

#pragma mark - FontAsset Logger

- (void)logFonts {
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);

        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}

@end
