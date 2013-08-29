//
//  EHFFacebookUtility.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAppDelegate.h"
#import "EHFFacebookUtility.h"
#import <FacebookSDK/FacebookSDK.h>
#import "EHFDataStore.h"
#import "EHFAlbumClass.h"
#import "EHFPhotoClass.h"
#import "EHFVideoClass.h"
#import "EHFEventClass.h"

@interface EHFFacebookUtility ()

@property (strong, nonatomic) FBRequestConnection *requestConnection;
@end

@implementation EHFFacebookUtility

EHFDataStore *data;
BOOL pageComplete = FALSE;
BOOL albumComplete = FALSE;
BOOL eventComplete = FALSE;
BOOL videoComplete = FALSE;

BOOL pageError = FALSE;
BOOL albumError = FALSE;
BOOL eventError = FALSE;
BOOL videoError = FALSE;

NSInteger expectedAlbums;
NSInteger expectedEvents;

NSString *fbID = @"321024947913270";

- (id) init
{
    if(( self = [super init] ))
    {
        data=[EHFDataStore getInstance];
    }
    
    return self;
}


-(void)printError: (NSError*)errormsg {
    NSLog(@"Error: %@", errormsg);
    NSLog(@"Error code: %d", errormsg.code);
    NSLog(@"Error message: %@", errormsg.localizedDescription);
}

-(void)authenticateFB{
    
    // Attempt to open the session. If the session is not open, show the user the Facebook login UX
    [FBSession openActiveSessionWithReadPermissions:@[@"basic_info"] allowLoginUI:true completionHandler:^(FBSession *session,
                                                                                                           FBSessionState status,
                                                                                                           NSError *error)
     {
         NSString *alertMessage, *alertTitle;
         if (error.fberrorShouldNotifyUser) {
             // If the SDK has a message for the user, surface it. This conveniently
             // handles cases like password change or iOS6 app slider state.
             alertTitle = @"Something Went Wrong";
             alertMessage = error.fberrorUserMessage;
         } else if (error.fberrorCategory == FBErrorCategoryAuthenticationReopenSession) {
             alertTitle = @"Session Error";
             alertMessage = @"Your current session is no longer valid. Please log in again.";
         } else if (error.fberrorCategory == FBErrorCategoryUserCancelled) {
                    NSLog(@"user cancelled login");
         }
         if (alertMessage !=NULL) {
             [[[UIAlertView alloc] initWithTitle:alertTitle
                                         message:alertMessage
                                        delegate:nil
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil] show];
         }
         
         // Did something go wrong during login? I.e. did the user cancel?
         if (status == FBSessionStateClosedLoginFailed || status == FBSessionStateCreatedOpening) {
             
             // If so, just send them round the loop again
             [[FBSession activeSession] closeAndClearTokenInformation];
             [FBSession setActiveSession:nil];
             NSLog(@"Failed to Authenticate");
             FBSession* session = [[FBSession alloc] init];
             [FBSession setActiveSession: session];
         }
         else
         {
             NSLog(@"Facebook Authentication Successfull");
             // Update now we've logged in
             [self retrieveAll];
             
         }
     }];
}

-(void)retrieveAll{
    [self sendPageRequest];
    [self sendAlbumsRequest];
    [self sendVideoRequest];
    [self sendEventsRequest];
}

- (void)sendPageRequest{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [FBRequestConnection startWithGraphPath:fbID
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
                              if(error) {
                                  [self printError: error];
                                  pageError = YES;
                                  [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                  [self sendNotification];
                                  return;
                              }
                              
                              data.info = (NSDictionary *)result;
                              [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                              
                              NSLog(@"Name Retrieved: %@", [data.info objectForKey:@"name"]);
                              pageComplete = YES;
                              [self sendNotification];
                          }];
}

- (void)sendAlbumsRequest{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    
    [FBRequestConnection startWithGraphPath:[fbID stringByAppendingString:@"/albums?fields=cover_photo,id,name"]
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              
                              if(error) {
                                  [self printError: error];
                                  albumError = TRUE;
                                  [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                  [self sendNotification];
                                  return;
                              }
                              expectedAlbums = (NSInteger)[(NSMutableArray*)[result data] count];
                              NSLog(@"You have %d album(s)", [(NSMutableArray*)[result data] count]);
                              [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                              
                              if(expectedAlbums>1){
                                  [data.albums removeAllObjects];
                              }
                              
                              for (NSDictionary* albumDict in (NSMutableArray*)[result data])
                              {
                                  EHFAlbumClass *newAlbum = [[EHFAlbumClass alloc] init];
                                  [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
                                  [FBRequestConnection startWithGraphPath:[@"/" stringByAppendingString: [albumDict objectForKey:@"cover_photo"]]
                                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                            
                                                            if(error) {
                                                                [self printError: error];
                                                                [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                                                return;
                                                            }
                                                            newAlbum.cover = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [(NSDictionary *)result objectForKey:@"picture"]]]]];
                                                            newAlbum.name = [albumDict objectForKey:@"name"];
                                                            newAlbum.albumId = [albumDict objectForKey:@"id"];
                                                            [data.albums addObject:newAlbum];
                                                            [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                                            
                                                            if([data.albums count] == expectedAlbums){
                                                                albumComplete = TRUE;
                                                                [self sendNotification];
                                                            }
                                                        }];
                                  [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
                                  [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/photos?fields=name,picture,source&limit=1000", [albumDict objectForKey:@"id"]]
                                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                            if(error) {
                                                                [self printError: error];
                                                                [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                                                return;
                                                            }
                                                            [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                                            for (NSDictionary* photoDict in (NSMutableArray*)[result data])
                                                            {
                                                                EHFPhotoClass *newPhoto = [[EHFPhotoClass alloc]init];
                                                                newPhoto.name = [photoDict objectForKey:@"name"];
                                                                newPhoto.photoId = [photoDict objectForKey:@"id"];
                                                                newPhoto.previewURL = [photoDict objectForKey:@"picture"];
                                                                newPhoto.fullURL = [photoDict objectForKey:@"source"];
                                                                [newAlbum.photos addObject:newPhoto];
                                                                
                                                            }
                                                            NSLog(@"You have %d photo(s) in the album %@", [(NSMutableArray*)[result data] count],[albumDict objectForKey:@"name"]);
                                                            
                                                        }];
                              }
                          }];
}

- (void)sendEventsRequest{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [FBRequestConnection startWithGraphPath:[fbID stringByAppendingString:@"/events?fields=description,end_time,id,location,name,start_time,venue,picture"]
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if(error) {
                                  [self printError: error];
                                  eventError = TRUE;
                                  [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                  [self sendNotification];
                                  return;
                              }
                              expectedEvents = (NSInteger)[(NSMutableArray*)[result data] count];
                              
                              if(expectedEvents>1){
                                  [data.events removeAllObjects];
                              }
                              
                              for (NSDictionary* eventDict in (NSMutableArray*)[result data])
                              {
                                  EHFEventClass *newEvent = [[EHFEventClass alloc] init];
                                  newEvent.eventId = [eventDict objectForKey:@"id"];
                                  newEvent.name = [eventDict objectForKey:@"name"];
                                  newEvent.description = [eventDict objectForKey:@"description"];
                                  newEvent.start = [eventDict objectForKey:@"start_time"];
                                  newEvent.end = [eventDict objectForKey:@"end_time"];
                                  newEvent.location = [eventDict objectForKey:@"location"];
                                  newEvent.venue = [eventDict objectForKey:@"venue"];
                                  
                                  NSDictionary *pictureDetails = [eventDict objectForKey:@"picture"];
                                  NSDictionary *picd = [pictureDetails objectForKey:@"data"];
                                  
                                  newEvent.pictureURL = [picd objectForKey:@"url"];
                                  newEvent.picture = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newEvent.pictureURL]]];
                                  
                                  [data.events addObject:newEvent];
                                  
                                  if([data.events count] == expectedEvents){
                                      eventComplete = TRUE;
                                      [self sendNotification];
                                  }
                              }
                              [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                              
                              NSLog(@"You have %d event(s)", [data.events count]);
                          }];
}


-(void)sendVideoRequest{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [FBRequestConnection startWithGraphPath:[fbID stringByAppendingString:@"/videos"]
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if(error) {
                                  [self printError: error];
                                  videoError = TRUE;
                                  [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                  [self sendNotification];
                                  return;
                              }
                              [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                              for (NSDictionary* videoDict in (NSMutableArray*)[result data])
                              {
                                  EHFVideoClass *newVideo = [[EHFVideoClass alloc]init];
                                  newVideo.description = [videoDict objectForKey:@"description"];
                                  newVideo.videoId = [videoDict objectForKey:@"id"];
                                  newVideo.previewURL = [videoDict objectForKey:@"picture"];
                                  newVideo.preview = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:newVideo.previewURL]]];
                                  newVideo.videoURL = [videoDict objectForKey:@"source"];
                                  [data.videos addObject:newVideo];
                              }
                              NSLog(@"You have %d video(s)", [(NSMutableArray*)[result data] count]);
                          }];
    videoComplete = TRUE;
    [self sendNotification];
}

-(void)sendNotification{
    NSDictionary *dataDict = [[NSMutableDictionary alloc] init];
    [dataDict setValue:[NSNumber numberWithBool:pageComplete] forKey:@"pageComplete"];
    [dataDict setValue:[NSNumber numberWithBool:albumComplete] forKey:@"albumComplete"];
    [dataDict setValue:[NSNumber numberWithBool:eventComplete] forKey:@"eventComplete"];
    [dataDict setValue:[NSNumber numberWithBool:videoComplete] forKey:@"videoComplete"];
    [dataDict setValue:[NSNumber numberWithBool:pageError] forKey:@"pageError"];
    [dataDict setValue:[NSNumber numberWithBool:albumError] forKey:@"albumError"];
    [dataDict setValue:[NSNumber numberWithBool:eventError] forKey:@"eventError"];
    [dataDict setValue:[NSNumber numberWithBool:videoError] forKey:@"videoError"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FBComplete" object:self userInfo:dataDict];
}
@end