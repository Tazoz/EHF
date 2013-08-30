//
//  EHFVideoClass.m
//  EHF
//
//  Created by Tass Grigoriou on 27/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAppDelegate.h"
#import "EHFVideoClass.h"

@implementation EHFVideoClass
@synthesize videoId;
@synthesize description;
@synthesize previewURL;
@synthesize videoURL;
@synthesize preview;

-(UIImage *) getImageFromURL :(NSString *) url{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
    return image;
}

@end
