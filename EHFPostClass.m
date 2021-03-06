//
//  EHFPostClass.m
//  EHF
//
//  Created by Tass Grigoriou on 3/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFPostClass.h"
#import "EHFAppDelegate.h"

@implementation EHFPostClass

@synthesize postId;
@synthesize name;
@synthesize created;
@synthesize message;
@synthesize photo;
@synthesize objectId;
@synthesize objectType;
@synthesize linkURL;
@synthesize comments;

- (id) init
{
    if(( self = [super init] ))
    {
        self.comments = [[NSMutableArray alloc] init];
    }
    return self;
}

@end
