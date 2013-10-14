//
//  EHFAbout.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAbout.h"
#import "EHFDataStore.h"

@interface EHFAbout ()

@end

@implementation EHFAbout

@synthesize txtAbout;

EHFDataStore *data;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    data=[EHFDataStore getInstance];
    NSString *AboutInfo;
    if ([data.info objectForKey:@"name"] !=nil)
    {
        if([data.info objectForKey:@"about"] == nil)
        {
            AboutInfo = [NSString stringWithFormat: @"%@ has not supplied any about information." , (NSString *)[data.info objectForKey:@"name"]];
        }else{
            AboutInfo = [(NSString *)[data.info objectForKey:@"description"] stringByTrimmingCharactersInSet:
                         [NSCharacterSet whitespaceAndNewlineCharacterSet]];
            self.coverPhoto.image = [data.info objectForKey:@"coverPhoto"];
        }
    }else{
        AboutInfo = [NSString stringWithFormat: @"No 'About Us' information supplied."];
    }
    txtAbout.text = [NSString stringWithFormat: @"%@",AboutInfo];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
