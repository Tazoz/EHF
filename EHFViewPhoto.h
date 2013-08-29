//
//  EHFViewPhoto.h
//  EHF
//
//  Created by Tass Grigoriou on 21/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHFPhotoClass.h"

@interface EHFViewPhoto : UIViewController{
    EHFPhotoClass *photo;
}

@property (strong, nonatomic) IBOutlet UIImageView *PhotoView;
@property(nonatomic, strong) EHFPhotoClass *photo;


@end
