//
//  EHFDataStore.h
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHFDataStore : NSObject
{
    NSMutableDictionary *info;
    NSMutableArray *albums;
    NSMutableArray *events;
    NSMutableArray *videos;
    NSMutableArray *posts;
}

@property(nonatomic,retain)NSMutableDictionary *info;
@property(nonatomic,retain)NSMutableArray *albums;
@property(nonatomic,retain)NSMutableArray *events;
@property(nonatomic,retain)NSMutableArray *videos;
@property(nonatomic,retain)NSMutableArray *posts;
+(EHFDataStore*)getInstance;

@end
