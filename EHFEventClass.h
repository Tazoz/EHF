//
//  EHFEventClass.h
//  EHF
//
//  Created by Tass Grigoriou on 27/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EHFEventClass : NSObject
{
    NSString *eventId;
    NSString *name;
    NSString *description;
    NSString *start;
    NSString *end;
    NSString *location;
    NSDictionary *venue;
    NSString *pictureURL;
    UIImage *picture;
}

@property(nonatomic,retain)NSString *eventId;
@property(nonatomic,retain)NSString *name;
@property(nonatomic,retain)NSString *description;
@property(nonatomic,retain)NSString *start;
@property(nonatomic,retain)NSString *end;
@property(nonatomic,retain)NSString *location;
@property(nonatomic,retain)NSDictionary *venue;
@property(nonatomic,retain)NSString *pictureURL;
@property(nonatomic,retain)UIImage *picture;

@end
