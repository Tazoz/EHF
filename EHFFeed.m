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
#import "EHFViewPost.h"
#import "EHFPhotoClass.h"
#import "EHFVideoClass.h"
#import "EHFAlbumClass.h"
#import <Socialize/Socialize.h>

@interface EHFFeed ()

@end

@implementation EHFFeed

EHFDataStore *data;
EHFFacebookUtility *fu;
UIRefreshControl *refreshControl;
NSDateFormatter *formatter;
NSString *postText;
UIAlertView *alert;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    data=[EHFDataStore getInstance];
    
    if([data.posts count] !=0)
    {
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

-(void)reloadTableValues
{
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

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
    if (cell == nil)
    {
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

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection" message:@"\nNo network connection to access post." delegate:self cancelButtonTitle:@"Back" otherButtonTitles:nil];
        [myAlert show];
    } else {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Retrieving Post" message:@"Please Wait..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
        [indicator startAnimating];
        [alert addSubview:indicator];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            EHFPostClass *post = [data.posts objectAtIndex:indexPath.row];
            
            if(post.photo.preview == nil && post.photo.photoId !=nil)
            {
                for(EHFAlbumClass *album in data.albums)
                {
                    for(EHFPhotoClass *photo in album.photos)
                    {
                        if([photo.photoId isEqualToString:post.objectId])
                        {
                            post.photo =nil;
                            post.photo = photo;
                            if(photo.preview == nil)
                            {
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
            EHFViewPost *pv = [self.storyboard instantiateViewControllerWithIdentifier:@"viewPostController"];
            pv.post = post;
            if (post.photo.preview !=nil || post.photo.photoId == nil)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                    [self.navigationController pushViewController:pv animated:YES];
                });
            }
        });
    }
}

-(void)showActionSheet:(id)sender
{
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"Select Photo To Attach"
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"No Photo", @"Take New Photo", @"Existing Photo", nil];
    [sheet showInView:self.view];
    
    SZCommentOptions *options = [SZCommentUtils userCommentOptions];
    options.dontShareLocation = TRUE;
}

-(void)imagePickerController: (UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *photo;
    if (info !=nil)
    {
        photo = info[UIImagePickerControllerEditedImage];
        [self dismissViewControllerAnimated:YES completion:^{
            [self addPostText :photo];
        }];
    }else{
        [self addPostText :nil];
    }
}

-(void)addPostText :(UIImage*)photo
{
    [SZCommentUtils showCommentComposerWithViewController:self
                                                   entity:[SZEntity
                                                           entityWithKey:[NSString stringWithFormat:@"Posted at %@", [NSDate date]]
                                                           name:[NSString stringWithFormat:@"%@ Facebook page post", [data.info objectForKey:@"name"]]]
                                               completion:^(id<SZComment> newPost) {
                                                   
                                                   if (photo ==nil)
                                                   {
                                                       [fu postOnWall:nil :[newPost text]];
                                                   }else{
                                                       [fu postPhoto:photo :[newPost text]];
                                                   }
                                               } cancellation:^{
                                                   NSLog(@"Cancelled comment create");
                                               }];
}

-(void)postComplete
{
    [alert setTitle:@"Success"];
    [alert setMessage:[NSString stringWithFormat:@"Successfully posted to the %@ Facebook page", [data.info objectForKey:@"name"]]];
    sleep(3);
    [self performSelector:@selector(dismissAlert) withObject:nil afterDelay:2];
}

-(void)dismissAlert
{
    [alert dismissWithClickedButtonIndex:0 animated:TRUE];
}

-(void)imagePickerControllerDidCancel: (UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(postComplete)
                                                 name:@"FBPostComplete"
                                               object:nil];
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    imagePicker.mediaTypes = @[(NSString *) kUTTypeImage];
    imagePicker.allowsEditing = YES;
    switch (buttonIndex)
    {
        case 0:
            [self imagePickerController:nil didFinishPickingMediaWithInfo:nil];
            break;
        case 1:
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypeCamera;
            [self presentViewController:imagePicker animated:YES completion:nil];
            break;
        case 2:
            imagePicker.sourceType =
            UIImagePickerControllerSourceTypePhotoLibrary;
            [self presentViewController:imagePicker animated:YES completion:nil];
            break;
    }
}

@end
