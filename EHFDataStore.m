//
//  EHFDataStore.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFDataStore.h"

@implementation EHFDataStore
@synthesize info;
@synthesize albums;
@synthesize events;
@synthesize videos;

static EHFDataStore *instance =nil;
+(EHFDataStore *)getInstance
{
    @synchronized(self)
    {
        if(instance==nil)
        {
            
            instance= [[EHFDataStore alloc] init];
        }
    }
    return instance;
}

- (id) init
{
    if(( self = [super init] ))
    {
        self.albums = [[NSMutableArray alloc] init];
        self.events = [[NSMutableArray alloc] init];
        self.videos = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
