//
//  EHFViewPhoto.m
//  EHF
//
//  Created by Tass Grigoriou on 21/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFViewPhoto.h"
#import "EHFPhotoClass.h"

@interface EHFViewPhoto ()
@end

@implementation EHFViewPhoto
@synthesize PhotoView;
@synthesize photo;


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

    if(photo.full == nil){
        photo.full = [photo getImageFromURL:photo.fullURL];
    }
    PhotoView.image = photo.full;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
