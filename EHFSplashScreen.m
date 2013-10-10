//
//  EHFSplashScreen.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFSplashScreen.h"
#import "EHFAppDelegate.h"
#import "EHFFacebookUtility.h"
#import "Reachability.h"

@interface EHFSplashScreen ()

@end

@implementation EHFSplashScreen

EHFFacebookUtility *fu;
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.hidden = YES;
    _spinner.hidden = true;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToNextView:)
                                                 name:@"FBComplete"
                                               object:nil];
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                          message:@"\nYou require an internet connection for EHF to work."
                                                         delegate:self
                                                cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        
    } else {
        fu = [[EHFFacebookUtility alloc]init];
               
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(failedFBAuth)
                                                     name:@"FBFailedAuth"
                                                   object:nil];
        
        [self.fbLoginButton addTarget:self
                               action:@selector(loginButtonSelected)
                     forControlEvents:UIControlEventTouchDown];
        
        [self.skipbutton addTarget:self
                            action:@selector(retrieveNonAuth)
                  forControlEvents:UIControlEventTouchDown];
    }
}

-(void)loginButtonSelected
{
    self.fbLoginButton.hidden = TRUE;
    self.skipbutton.hidden=TRUE;
    [_spinner startAnimating];
    self.lblLoading.hidden = FALSE;
    self.aiSpinner.hidden = FALSE;
    
    [(EHFAppDelegate *) [[UIApplication sharedApplication] delegate] authenticateFacebook];
}

-(void)failedFBAuth
{
    UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Authentication Failed"
                                                      message:@"\nFacebook failed to Authenticate.\nWill proceed as a non authenticated user..."
                                                     delegate:self
                                            cancelButtonTitle:nil otherButtonTitles: @"OK",nil];
    [myAlert show];
    [self retrieveNonAuth];
}

-(void)retrieveNonAuth
{
    [_spinner startAnimating];
    self.lblLoading.hidden = FALSE;
    self.aiSpinner.hidden = FALSE;
    
    self.fbLoginButton.hidden = TRUE;
    self.skipbutton.hidden=TRUE;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if(![[defaults objectForKey:@"FuturePrompt"] isEqualToString: @"FALSE"]){
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Request Authentication"
                                                          message:@"\nMany EHF features require Facebook authentication."
                                                         delegate:self
                                                cancelButtonTitle:@"Login Now"
                                                otherButtonTitles:@"Only ask when required",nil];
        [myAlert show];
    }else{
        [fu retrieveNonAuth];
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"FALSE" forKey:@"FBAuthenticated"];
    
    if (buttonIndex == [alertView cancelButtonIndex]){
        [self loginButtonSelected];
    }else{
        [defaults setObject:@"FALSE" forKey:@"FuturePrompt"];
        [self retrieveNonAuth];
    }
    
    [defaults synchronize];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)goToNextView:(NSNotification *)status
{
    NSDictionary *dataDict = [status userInfo];
    NSNumber* pageComplete = [dataDict objectForKey:@"pageComplete"];
    NSNumber* albumComplete = [dataDict objectForKey:@"albumComplete"];
    NSNumber* eventComplete = [dataDict objectForKey:@"eventComplete"];
    NSNumber* videoComplete = [dataDict objectForKey:@"videoComplete"];
    NSNumber* feedComplete = [dataDict objectForKey:@"feedComplete"];
    
    NSNumber* pageError = [dataDict objectForKey:@"pageError"];
    NSNumber* albumError = [dataDict objectForKey:@"albumError"];
    NSNumber* eventError = [dataDict objectForKey:@"eventError"];
    NSNumber* videoError = [dataDict objectForKey:@"videoError"];
    NSNumber* feedError = [dataDict objectForKey:@"feedError"];
    
    if([pageComplete boolValue] == TRUE){
        //NSLog(@"CHECK 1");
        if([albumComplete boolValue] == TRUE || [albumError boolValue] == TRUE){
            //  NSLog(@"CHECK 2");
            if([eventComplete boolValue] == TRUE || [eventError boolValue] == TRUE){
                //    NSLog(@"CHECK 3");
                if([videoComplete boolValue] == TRUE || [videoError boolValue] == TRUE){
                    //      NSLog(@"CHECK 4");
                    if([feedComplete boolValue] == TRUE || [feedError boolValue] == TRUE){
                        //        NSLog(@"CHECK 5");
                        [_spinner stopAnimating];
                        [self performSegueWithIdentifier:@"menuSegue" sender:self];
                    }
                    
                }
            }
            
        }
    }else{
        
        if([pageError boolValue] == TRUE){
            [_spinner stopAnimating];
            UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Information Inaccessible"
                                                              message:@"\nInformation required for this app is inaccessible.\nPlease try again later."
                                                             delegate:self
                                                    cancelButtonTitle:nil otherButtonTitles:nil];
            [myAlert show];
        }
    }
}


@end
