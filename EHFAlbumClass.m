//
//  EHFAlbumClass.m
//  EHF
//
//  Created by Tass Grigoriou on 21/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAlbumClass.h"

@implementation EHFAlbumClass

@synthesize albumId;
@synthesize name;
@synthesize cover;
@synthesize photos;


- (id) init
{
    if(( self = [super init] ))
    {
        self.photos = [[NSMutableArray alloc] init];
    }
    return self;
}
@end
