//
//  EHFPhotoCollection.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFPhotoCollection.h"
#import "EHFAlbumClass.h"
#import "EHFPhotoClass.h"
#import "EHFMediaItem.h"
#import "EHFViewPhoto.h"
#import "Reachability.h"

@implementation EHFPhotoCollection
@synthesize album;

-(void)viewWillAppear {
    [super viewWillAppear:YES];
    [self.collectionView reloadData];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.album.photos count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EHFMediaItem *mItem = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    EHFPhotoClass *photo = self.album.photos[indexPath.row];
    
    mItem.photo = photo;
    [mItem.image setImage: photo.preview];
    
    if(photo.preview == [UIImage imageNamed:@"Logo.jpg"])
    {
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0ul);
        dispatch_async(queue, ^{
            UIImage *image;
            
            image = [UIImage imageWithData:[NSData dataWithContentsOfURL:
                                            [NSURL URLWithString:photo.previewURL]]];
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                photo.preview = image;
                [mItem.image setImage: image];
                [mItem setNeedsLayout];
            });
        });
    }
    return mItem;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable)
    {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                          message:@"\nNo network connection to access photo."
                                                         delegate:self
                                                cancelButtonTitle:@"Back" otherButtonTitles:nil];
        [myAlert show];
    } else {
        UIAlertView *alert;
        
        alert = [[UIAlertView alloc] initWithTitle:@"Enlarging Photo" message:@"Please Wait..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
        [alert show];
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
        [indicator startAnimating];
        [alert addSubview:indicator];
        
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            EHFPhotoClass *photo = self.album.photos[indexPath.row];
            
            EHFViewPhoto *photoView = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoView"];
            photoView.photo = photo;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [alert dismissWithClickedButtonIndex:0 animated:YES];
                [self.navigationController pushViewController:photoView animated:YES];
            });
        });
    }
}
@end
