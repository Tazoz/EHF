//
//  EHFVideoClass.h
//  EHF
//
//  Created by Tass Grigoriou on 27/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHFVideoClass : NSObject
{
    NSString *videoId;
    NSString *description;
    NSString *previewURL;
    NSString *fullURL;
    UIImage *preview;
    
}

@property(nonatomic,retain)NSString *videoId;
@property(nonatomic,retain)NSString *description;
@property(nonatomic,retain)NSString *previewURL;
@property(nonatomic,retain)NSString *videoURL;
@property(nonatomic,retain)UIImage *preview;


-(UIImage*)getImageFromURL:(NSString *)url;

@end
