//
//  EHFFeed.m
//  EHF
//
//  Created by Tass Grigoriou on 3/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAppDelegate.h"
#import "EHFFeed.h"
#import "EHFDataStore.h"
#import "EHFFacebookUtility.h"
#import "Reachability.h"
#import "EHFPostClass.h"
#import "EHFEntryItem.h"
#import "EHFPost.h"
#import "EHFPhotoClass.h"
#import "EHFVideoClass.h"
#import "EHFAlbumClass.h"

@interface EHFFeed ()

@end

@implementation EHFFeed

EHFDataStore *data;
EHFFacebookUtility *fu;
UIRefreshControl *refreshControl;
NSDateFormatter *formatter;

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
    
    if([data.posts count] !=0){
        _noFeed.hidden = YES;
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    formatter = [[NSDateFormatter alloc] init];
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Pull to refresh"]];
    [refreshControl addTarget:self action:@selector(refreshPostsList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

-(void)refreshPostsList{
    [formatter setDateFormat:@"MMM d, HH:mm"];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]]];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableValues)
                                                 name:@"FBComplete"
                                               object:nil];
    [fu sendFeedRequest];
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
    return [data.posts count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EHFEntryItem *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil) {
        cell = [[EHFEntryItem alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    EHFPostClass *post = [data.posts objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormat dateFromString:post.created];
    [formatter setDateFormat:@"dd MMM 'at' HH:mm"];
    
    cell.title.text = post.message;
    cell.primaryDetail.text = post.name;
    cell.secondaryDetail.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block EHFPost *pv;
    
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"\nNo network connection to access post." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil];
        [myAlert show];
        
    } else {
        UIAlertView *alert;
        [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
        alert = [[UIAlertView alloc] initWithTitle:@"Retrieving Post From Network\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
        [indicator startAnimating];
        [alert addSubview:indicator];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            EHFPostClass *post = [data.posts objectAtIndex:indexPath.row];
            pv = [self.storyboard instantiateViewControllerWithIdentifier:@"postView"];
            
            if(post.photo.preview == Nil)
            {
                for(EHFAlbumClass *album in data.albums)
                {
                    for(EHFPhotoClass *photo in album.photos)
                    {
                        if([photo.photoId isEqualToString:post.objectId])
                        {
                            post.photo =nil;
                            post.photo = photo;
                            if(photo.preview == nil){
                               
                                post.photo.preview = [photo getImageFromURL:photo.previewURL];
                            }
                            break;
                        }
                    }
                }
                
                if (post.photo.preview == nil)
                {
                    EHFPhotoClass *newPhoto = [[EHFPhotoClass alloc]init];
                    post.photo.preview = [newPhoto getImageFromURL:post.photo.previewURL];
                    post.photo.fullURL = post.photo.fullURL;
                    post.photo.name = post.message;
                }
            }
            
            pv.post = post;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
                [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                [self.navigationController pushViewController:pv animated:YES];
            });
        });
    }
}

@end
