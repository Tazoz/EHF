//
//  EHFPost.m
//  EHF
//
//  Created by Tass Grigoriou on 3/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFPost.h"
#import "Reachability.h"
#import "EHFViewPhoto.h"
#import "EHFDataStore.h"

@interface EHFPost ()

@end

@implementation EHFPost
@synthesize post;

EHFDataStore *data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    data=[EHFDataStore getInstance];
    self.image.image = post.photo.preview;
    
    if(post.photo ==nil){
        self.image.hidden = true;
    }
    
    self.postText.text = post.message;
    self.navigationItem.title = post.message;
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToContentView)];
    
    self.image.userInteractionEnabled = YES;
    
    [self.image addGestureRecognizer:imageTap];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [post.comments count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"Cell";
    EHFEntryItem *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[EHFEntryItem alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    EHFPostClass *reply = [post.comments objectAtIndex:indexPath.row];
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH:mm:ssZ"];
    NSDate *date = [dateFormat dateFromString:reply.created];
    NSDateFormatter *formatter;
    [formatter setDateFormat:@"dd MMM 'at' HH:mm"];
    
    cell.title.text = reply.message;
    cell.primaryDetail.text = reply.name;
    cell.secondaryDetail.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
}

-(void) goToContentView
{
    if ([post.objectType isEqualToString:@"video"])
    {
        EHFVideoClass *videoToView;
        
        for (EHFVideoClass *video in data.videos)
        {
            if([video.videoId isEqualToString:post.objectId])
            {
                videoToView = video;
            }
        }
        
        MPMoviePlayerController *moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:[[NSURL alloc] initWithString:videoToView.videoURL]];
        [moviePlayer prepareToPlay];
        
        moviePlayer.view.frame = self.view.bounds;
        moviePlayer.controlStyle=MPMovieControlStyleFullscreen;
        moviePlayer.movieSourceType = MPMovieSourceTypeFile;
        moviePlayer.shouldAutoplay=YES;
        [moviePlayer setFullscreen:YES animated:YES];
        self.myPlayer = moviePlayer;
        
        UIWindow *backgroundWindow = [[UIApplication sharedApplication] keyWindow];
        [moviePlayer.view setFrame:backgroundWindow.frame];
        [backgroundWindow addSubview:self.myPlayer.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:self.myPlayer];
        [self.myPlayer play];
        
    }else{
        
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
            UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                              message:@"\nNo network connection to access photo."
                                                             delegate:self
                                                    cancelButtonTitle:@"Back" otherButtonTitles:nil];
            [myAlert show];
            
        } else {
            
            UIAlertView *alert;
            
            alert = [[UIAlertView alloc] initWithTitle:@"Enlarging Photo From Network\nPlease Wait..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [alert show];
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
            [indicator startAnimating];
            [alert addSubview:indicator];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                EHFViewPhoto *photoView = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoView"];
                
                photoView.photo = post.photo;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                    [self.navigationController pushViewController:photoView animated:YES];
                });
            });
        }
    }
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    MPMoviePlayerController *player = [notification object];
    [player.view removeFromSuperview];
}
@end
