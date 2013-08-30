//
//  EHFMediaItem.h
//  EHF
//
//  Created by Tass Grigoriou on 27/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHFPhotoClass.h"
#import "EHFVideoClass.h"

@interface EHFMediaItem : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property(nonatomic, strong) EHFPhotoClass *photo;
@property(nonatomic, strong) EHFVideoClass *video;

@end
