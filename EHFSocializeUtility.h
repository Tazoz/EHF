//
//  EHFSocializeUtility.h
//  EHF
//
//  Created by Tass Grigoriou on 13/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Socialize/Socialize.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "EHFDataStore.h"
#import "EHFPhotoClass.h"
#import "EHFFacebookUtility.h"
#import <FacebookSDK/FacebookSDK.h>

@interface EHFSocializeUtility : NSObject

@property (nonatomic, retain) SZActionBar *actionBar;
@property (nonatomic, retain) id<SZEntity> entity;
@property (nonatomic, retain) SZLikeButton *likeButton;
@property (strong, atomic) ALAssetsLibrary* library;

-(id)generateActionBar:(NSString*)key :(NSString*)name :(NSString*)type :(id)object :(UIViewController*)sender;
- (void)didCreate:(NSNotification*)notification;
@end