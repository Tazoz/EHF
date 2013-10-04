//
//  EHFContact.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFContact.h"
#import "EHFDataStore.h"
#import <GoogleMaps/GoogleMaps.h>

@interface EHFContact ()

@end

EHFDataStore *data;

@implementation EHFContact{
    GMSMapView *mapView_;
    
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    data=[EHFDataStore getInstance];
    NSDictionary *loc = [data.info objectForKey:@"location"];
    
    _txtName.text = [data.info objectForKey:@"name"];
    _txtAddress.text = [NSString stringWithFormat: @"Address:\n%@\n%@, %@\n%@, %@",[loc objectForKey:@"street"],[loc objectForKey:@"city"],[loc objectForKey:@"zip"],[loc objectForKey:@"state"],[loc objectForKey:@"country"]];
    
    _txtPhone.text = [NSString stringWithFormat:@"Phone:  %@", [data.info objectForKey:@"phone"]];
    _txtWebsite.text = [NSString stringWithFormat:@"Website:\n%@", [data.info objectForKey:@"link"]];
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[[loc objectForKey:@"latitude"] floatValue]
                                                            longitude:[[loc objectForKey:@"longitude"] floatValue]
                                                                 zoom:15];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectMake(0, 100, CGRectGetWidth(self.view.bounds), 200) camera: camera];
    mapView_.myLocationEnabled = YES;
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = CLLocationCoordinate2DMake([[loc objectForKey:@"latitude"] floatValue], [[loc objectForKey:@"longitude"] floatValue]);
    marker.title = [data.info objectForKey:@"name"];
    marker.snippet = @"Mazenod College Gymnasium";
    marker.map = mapView_;
    
    mapView_.userInteractionEnabled = YES;
    [self.view addSubview:mapView_];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
