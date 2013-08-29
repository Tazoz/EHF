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
    NSDictionary *info;
    NSMutableArray *albums;
    NSMutableArray *events;
    NSMutableArray *videos;
}

@property(nonatomic,retain)NSDictionary *info;
@property(nonatomic,retain)NSMutableArray *albums;
@property(nonatomic,retain)NSMutableArray *events;
@property(nonatomic,retain)NSMutableArray *videos;
+(EHFDataStore*)getInstance;

@end
