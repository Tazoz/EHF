//
//  EHFEvent.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFEvent.h"

@interface EHFEvent ()

@end

@implementation EHFEvent
@synthesize event;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    _eventImage.image = event.picture;
    _eventName.text = event.name;
    _eventStart.text = event.start;
    _eventDescription.text = event.description;
    self.navigationItem.title = event.name;
    
    if(event.end == NULL)
    {
     _eventEnd.text = @"No End Time Provided";
    }else{
    _eventEnd.text = event.end;
    }
    if(event.location == NULL)
    {
        _eventLocation.text = @"No Location Provided";
    }else{
        _eventLocation.text = event.location;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
