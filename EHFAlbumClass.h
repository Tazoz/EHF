//
//  EHFAlbumClass.h
//  EHF
//
//  Created by Tass Grigoriou on 21/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHFAlbumClass : NSObject
{
    NSString *albumId;
    NSString *name;
    UIImage *cover;
    NSMutableArray *photos;
}

@property(nonatomic,retain)NSString *albumId;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)UIImage *cover;
@property(nonatomic,retain)NSMutableArray *photos;
@end
