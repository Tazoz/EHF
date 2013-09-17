//
//  EHFSplashScreen.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFSplashScreen.h"
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(goToNextView:)
                                                 name:@"FBComplete"
                                               object:nil];
    
    [_spinner startAnimating];
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        [_spinner stopAnimating];
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                          message:@"\nYou require an internet connection for EHF to work."
                                                         delegate:self
                                                cancelButtonTitle:nil otherButtonTitles:nil];
        [myAlert show];
        
    } else {
        fu = [[EHFFacebookUtility alloc]init];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [fu authenticateFB];
            dispatch_async(dispatch_get_main_queue(), ^{
               [fu retrieveAll];
            });
        });
    }
}


#pragma mark - View lifecycle

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
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
