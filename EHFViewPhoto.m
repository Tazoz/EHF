//
//  EHFViewPhoto.m
//  EHF
//
//  Created by Tass Grigoriou on 21/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFViewPhoto.h"
#import "EHFPhotoClass.h"
#import "EHFSocializeUtility.h"

@interface EHFViewPhoto ()
@end

@implementation EHFViewPhoto
@synthesize PhotoView;
@synthesize photo;

EHFDataStore *data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    data=[EHFDataStore getInstance];
    
    if(photo.full == nil)
    {
        photo.full = [photo getImageFromURL:photo.fullURL];
    }
    
    self.navigationItem.title = photo.name;
    PhotoView.image = photo.full;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    EHFSocializeUtility *su = [[EHFSocializeUtility alloc]init];
    [self.view addSubview:[su generateActionBar:[NSString stringWithFormat:@"fbPhoto%@", photo.photoId] :photo.name :@"photo" :photo :self]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
