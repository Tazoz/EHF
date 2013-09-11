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
    
    self.navigationItem.title = photo.name;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture)];
    tapGesture.numberOfTapsRequired=1;
    [PhotoView setUserInteractionEnabled:YES];
    [PhotoView addGestureRecognizer:tapGesture];
    PhotoView.image = photo.full;
}

-(void)handleTapGesture{
    
    
    if(self.navigationController.navigationBar.hidden){
        [[self navigationController] setNavigationBarHidden:NO animated:NO];
    }else{
        [[self navigationController] setNavigationBarHidden:YES animated:NO];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
