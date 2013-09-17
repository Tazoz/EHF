//
//  EHFPostClass.h
//  EHF
//
//  Created by Tass Grigoriou on 3/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHFPhotoClass.h"

@interface EHFPostClass : NSObject
{
    NSString *postId;
    NSString *created;
    NSString *name;
    NSString *message;
    NSString *objectId;
    NSString *objectType;
    NSString *linkURL;
    EHFPhotoClass *photo;
    NSMutableArray *comments;
}

@property(nonatomic,retain)NSString *postId;
@property(nonatomic,retain)NSString *created;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *message;
@property(nonatomic,retain)NSString *objectId;
@property(nonatomic,retain)NSString *objectType;
@property(nonatomic,retain)NSString *linkURL;
@property(nonatomic,retain)EHFPhotoClass *photo;
@property(nonatomic,retain)NSMutableArray *comments;

@end
