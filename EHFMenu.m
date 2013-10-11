//
//  EHFMenu.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAppDelegate.h"
#import "EHFMenu.h"
#import "EHFMenuItem.h"
#import "EHFDataStore.h"


@interface EHFMenu ()
{
    NSArray *arrayOfImages;
    NSArray *arrayOfTitles;
    NSArray *arrayOfSegues;
    NSString *segue;
}

@end

@implementation EHFMenu

EHFDataStore *data;
UIAlertView *alert;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    data=[EHFDataStore getInstance];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    
    [[self MenuCollectionView]setDataSource:self];
    [[self MenuCollectionView]setDelegate:self];
    
    arrayOfImages = [[NSArray alloc]initWithObjects:@"about.png", @"events.png", @"photos.png", @"store.png", @"videos.png", @"feed.png", @"chat.png", @"contact.png", nil];
    arrayOfTitles = [[NSArray alloc]initWithObjects:@"About Us", @"Events", @"Photos", @"Store", @"Videos", @"Social Feed", @"Live Forum", @"Contact Us", nil];
    arrayOfSegues = [[NSArray alloc]initWithObjects:@"aboutSegue", @"eventsSegue", @"albumListSegue", @"storeSegue", @"videoSegue", @"feedSegue", @"chatSegue", @"contactSegue", nil];
    
    
    if ([[(NSUserDefaults*) [NSUserDefaults standardUserDefaults] objectForKey:@"FBAuthenticated"] isEqualToString:@"FALSE"])
    {
        
        [self.btnLogin addTarget:self
                          action:@selector(fbLogin)
                forControlEvents:UIControlEventTouchDown];
    }else{
        self.btnLogin.hidden = TRUE;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(hideLogin)
                                                 name:@"FBComplete"
                                               object:nil];
}

- (void)fbLogin
{
    UIActionSheet * action = [[UIActionSheet alloc]
                              initWithTitle:nil
                              delegate:self
                              cancelButtonTitle:nil
                              destructiveButtonTitle:@"Cancel"
                              otherButtonTitles:@"Login to Facebook",nil];
    
    [action showInView:self.view];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex: (NSInteger)buttonIndex{
    if (buttonIndex == 1) {
        [self notifyFBLogin];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrayOfTitles count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    EHFMenuItem *mItem = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [[mItem MenuItemImage]setImage: [UIImage imageNamed:[arrayOfImages objectAtIndex:indexPath.item]]];
    [[mItem MenuItemText]setText:[arrayOfTitles objectAtIndex:indexPath.item]];
    
    return mItem;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    segue = arrayOfSegues[row];
    NSArray *needAuth = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:1], [NSNumber numberWithInteger:4], [NSNumber numberWithInteger:5], nil];
    
    if([[(NSUserDefaults*) [NSUserDefaults standardUserDefaults] objectForKey:@"FBAuthenticated"]isEqualToString:@"FALSE"] && [needAuth containsObject: [NSNumber numberWithInteger:indexPath.row]])
    {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"Request Authentication"
                                                          message:@"\nFacebook authentication is required for this feature."
                                                         delegate:self
                                                cancelButtonTitle:@"Cancel" otherButtonTitles:@"Login now",nil];
        [myAlert show];
    }else{
        
        if (indexPath.row == 6)
        {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreate:) name:SZDidCreateObjectsNotification object:nil];
            SZEntity *entity = [SZEntity entityWithKey:@"EHFChat" name:[NSString stringWithFormat:@"%@ Chat",[data.info objectForKey:@"name"]]];
            [SZCommentUtils showCommentsListWithViewController:self entity:entity completion:nil];
            SZShareOptions *options = [SZShareUtils userShareOptions];
            
            options.dontShareLocation = YES;
            
        }else{
            [self performSegueWithIdentifier:segue sender:self];
            segue = nil;
        }
    }
}

-(void)hideLogin
{
    self.btnLogin.hidden = TRUE;
    [alert dismissWithClickedButtonIndex:0 animated:TRUE];
    
    if (segue !=nil){
        [self performSegueWithIdentifier:segue sender:self];
        segue = nil;
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:@"FALSE" forKey:@"FBAuthenticated"];
    
    if (buttonIndex != [alertView cancelButtonIndex]){
        [self notifyFBLogin];
    }
    [defaults synchronize];
}

-(void)notifyFBLogin
{
    [(EHFAppDelegate *) [[UIApplication sharedApplication] delegate] authenticateFacebook];
    
    alert = [[UIAlertView alloc] initWithTitle:@"Logging into Facebook" message:@"Please Wait..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
    [alert show];
    UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
    [indicator startAnimating];
    [alert addSubview:indicator];
}

@end
