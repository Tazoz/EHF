//
//  EHFAppDelegate.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAppDelegate.h"
#import "EHFFacebookUtility.h"
#import <GoogleMaps/GoogleMaps.h>
#import <FacebookSDK/FacebookSDK.h>
#import <Socialize/Socialize.h>

@implementation EHFAppDelegate

EHFFacebookUtility *fu;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    fu = [[EHFFacebookUtility alloc]init];
    
    [FBLoginView class];
    
    [GMSServices provideAPIKey:@"AIzaSyBWgaXbHXlmGhPR0s6Ag43Kjkj6-KDMAe8"];
    [Socialize storeConsumerKey:@"62aaaf8c-402b-4844-81c4-8e57aa4de9e1"];
    [Socialize storeConsumerSecret:@"8b6a4a69-ede2-431a-a74d-41472806e2cf"];
    [SZFacebookUtils setAppId:@"143051672569889"];
    [Socialize storeOGLikeEnabled:YES];
    
    // Register for Apple Push Notification Service
    [application registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound)];
    
    // Handle Socialize notification at launch
    NSDictionary *userInfo = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo != nil) {
        //        [self handleNotification:userInfo];
    }
    
    // Specify a Socialize entity loader block
    [Socialize setEntityLoaderBlock:^(UINavigationController *navigationController, id<SocializeEntity>entity) {
        
        [self entityLoader:navigationController :entity];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(retrieveFacebook)
                                                 name:@"FBAuthenticated"
                                               object:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [[FBSession activeSession] close];
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    //[[NSNotificationCenter defaultCenter] postNotificationName:OPEN_URL object:url];
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //[[NSNotificationCenter defaultCenter] postNotificationName:OPEN_URL object:url];
    //return [FBSession.activeSession handleOpenURL:url];
    return [Socialize handleOpenURL:url];
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)setVisible {
    static NSInteger NumberOfCallsToSetVisible = 0;
    if (setVisible)
        NumberOfCallsToSetVisible++;
    else
        NumberOfCallsToSetVisible--;
    
    // The assertion helps to find programmer errors in activity indicator management.
    // Since a negative NumberOfCallsToSetVisible is not a fatal error,
    // it should probably be removed from production code.
    NSAssert(NumberOfCallsToSetVisible >= 0, @"Network Activity Indicator was asked to hide more often than shown");
    
    // Display the indicator as long as our static counter is > 0.
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:(NumberOfCallsToSetVisible > 0)];
}

-(void)retrieveFacebook
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![[defaults objectForKey:@"NonAuthAccess"] isEqualToString: @"TRUE"]){
        [fu retrieveAll];
    }else{
        [fu addAuth];
    }
}

-(void)authenticateFacebook
{
    [fu authenticateFB];
}

-(void) entityLoader :(UINavigationController*) navigationController :(id<SocializeEntity>)entity
{
//    SampleEntityLoader *entityLoader = [[SampleEntityLoader alloc] initWithEntity:entity];
//    
//    if (navigationController == nil) {
//        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:entityLoader];
//        [self.window.rootViewController presentModalViewController:navigationController animated:YES];
//    } else {
//        [navigationController pushViewController:entityLoader animated:YES];
//    }
}

@end
