//
//  EHFPhotoClass.h
//  EHF
//
//  Created by Tass Grigoriou on 21/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHFPhotoClass : NSObject
{
    NSString *photoId;
    NSString *name;
    NSString *previewURL;
    NSString *fullURL;
    UIImage *preview;
    UIImage *full;
}

@property(nonatomic,retain)NSString *photoId;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *previewURL;
@property(nonatomic,retain)NSString *fullURL;
@property(nonatomic,retain)UIImage *preview;
@property(nonatomic,retain)UIImage *full;

  -(UIImage*)getImageFromURL:(NSString *)url;

@end
