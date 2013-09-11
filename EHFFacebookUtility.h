//
//  EHFFacebookUtility.h
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EHFAlbumClass.h"

@interface EHFFacebookUtility : NSObject

-(void)authenticateFB;
-(void)retrieveAll;
-(void)sendPageRequest;
-(void)sendAlbumsRequest;
-(void)sendEventsRequest;
-(void)sendVideoRequest;
-(void)sendFeedRequest;

@end
