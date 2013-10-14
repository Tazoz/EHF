//
//  EHFPhotoClass.m
//  EHF
//
//  Created by Tass Grigoriou on 21/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAppDelegate.h"
#import "EHFPhotoClass.h"

@implementation EHFPhotoClass

@synthesize photoId;
@synthesize name;
@synthesize previewURL;
@synthesize fullURL;
@synthesize preview;
@synthesize full;


-(UIImage *) getImageFromURL :(NSString *) url
{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PhotoDownloaded" object:self userInfo:nil];
    return image;
}

@end
