//
//  EHFEvent.h
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHFEventClass.h"

@interface EHFEvent : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *eventImage;
@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UITextView *eventStart;
@property (weak, nonatomic) IBOutlet UITextView *eventEnd;
@property (weak, nonatomic) IBOutlet UITextView *eventLocation;
@property (weak, nonatomic) IBOutlet UITextView *eventDescription;

@property(nonatomic, strong) EHFEventClass *event;

@end
