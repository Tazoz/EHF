//
//  EHFViewPhoto.h
//  EHF
//
//  Created by Tass Grigoriou on 21/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Socialize/Socialize.h>
#import "EHFPhotoClass.h"
#import "EHFDataStore.h"

@interface EHFViewPhoto : UIViewController{
    EHFPhotoClass *photo;
}

@property (strong, nonatomic) IBOutlet UIImageView *PhotoView;
@property(nonatomic, strong) EHFPhotoClass *photo;
@property (nonatomic, retain) SZActionBar *actionBar;
@property (nonatomic, retain) id<SZEntity> entity;

@end
