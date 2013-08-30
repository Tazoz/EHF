//
//  EHFAlbumsList.m
//  EHF
//
//  Created by Tass Grigoriou on 22/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAppDelegate.h"
#import "EHFAlbumsList.h"
#import "EHFDataStore.h"
#import "EHFAlbumClass.h"
#import "EHFPhotoCollection.h"
#import "EHFFacebookUtility.h"
#import "Reachability.h"

@interface EHFAlbumsList ()

@end

@implementation EHFAlbumsList

EHFDataStore *data;
EHFFacebookUtility *fu;
UIRefreshControl *refreshControl;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    data=[EHFDataStore getInstance];
    
    if([data.albums count] !=0){
        _noAlbum.hidden = YES;
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refreshAlbumList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

-(void)refreshAlbumList{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableValues)
                                                 name:@"FBComplete"
                                               object:nil];
    [fu sendAlbumsRequest];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MMM d, HH:mm"];
    //refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]]];
}

-(void)reloadTableValues{
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data.albums count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    EHFAlbumClass *album = [data.albums objectAtIndex:indexPath.row];
    
    cell.textLabel.text = album.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%d", [album.photos count]];
    cell.imageView.image = album.cover;
    
    UIGraphicsBeginImageContext(CGSizeMake(50, 50));
    CGRect imageRect = CGRectMake(0.0, 0.0, 50, 50);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block EHFPhotoCollection *pc;

   if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
       UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"\nNo network connection to access photos." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil];
        [myAlert show];
        
    } else {
                UIAlertView *alert;
        [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        alert = [[UIAlertView alloc] initWithTitle:@"Retrieving Photos From Network\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
        [indicator startAnimating];
        [alert addSubview:indicator];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            EHFAlbumClass *album = [data.albums objectAtIndex:indexPath.row];
            pc = [self.storyboard instantiateViewControllerWithIdentifier:@"photoCollection"];
            pc.album = album;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
                [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                [self.navigationController pushViewController:pc animated:YES];
            });
        });
    }
}
@end
