//
//  EHFVideoCollection.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFVideoCollection.h"
#import "EHFDataStore.h"
#import "EHFMediaItem.h"
#import "EHFVideoClass.h"
#import <MediaPlayer/MediaPlayer.h>

EHFDataStore *data;

@implementation EHFVideoCollection

- (id) init
{
    if(( self = [super init] ))
    {
        data=[EHFDataStore getInstance];
    }
    
    if([data.videos count]==0)
    {
        self.title = @"No Videos";
    }
    
    return self;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [data.videos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    EHFMediaItem *mItem = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    EHFVideoClass *video = data.videos[indexPath.row];
    
    if(video.preview == Nil){
        UIImage *preview = [video getImageFromURL:video.previewURL];
        video.preview = preview;
    }
    
    mItem.video = video;
    [mItem.image setImage: video.preview];
    return mItem;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    EHFVideoClass *video = data.videos[indexPath.row];
    
    MPMoviePlayerController *moviePlayer=[[MPMoviePlayerController alloc] initWithContentURL:[[NSURL alloc] initWithString:video.videoURL]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayBackDidFinish:) name:MPMoviePlayerPlaybackDidFinishNotification object:moviePlayer];
    
    moviePlayer.controlStyle=MPMovieControlStyleDefault;
    moviePlayer.shouldAutoplay=YES;
    [self.view addSubview:moviePlayer.view];
    [moviePlayer setFullscreen:YES animated:YES];
    
}

- (void) moviePlayBackDidFinish:(NSNotification*)notification
{
    
    MPMoviePlayerController *player = [notification object];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:player];
    
    if ([player respondsToSelector:@selector(setFullscreen:animated:)])
    {
        [player.view removeFromSuperview];
    }
}
@end
