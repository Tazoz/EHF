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
#import <Socialize/Socialize.h>
#import "EHFDataStore.h"
#import "EHFAlbumClass.h"
#import "EHFPhotoClass.h"
#import "EHFVideoClass.h"
#import "EHFEventClass.h"
#import "EHFPostClass.h"

@interface EHFFacebookUtility ()

@property (strong, nonatomic) FBRequestConnection *requestConnection;
@end

@implementation EHFFacebookUtility

EHFDataStore *data;
BOOL pageComplete = FALSE;
BOOL albumComplete = FALSE;
BOOL eventComplete = FALSE;
BOOL videoComplete = FALSE;
BOOL feedComplete = FALSE;

BOOL pageError = FALSE;
BOOL albumError = FALSE;
BOOL eventError = FALSE;
BOOL videoError = FALSE;
BOOL feedError = FALSE;

NSInteger expectedAlbums;
NSInteger expectedEvents;
NSInteger expectedPosts;

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
             
             if([data.info objectForKey:@"id"] == nil){
                 [[NSNotificationCenter defaultCenter] postNotificationName:@"FBAuthenticated" object:self];
             }
             
             NSString *existingToken =  [session accessTokenData].accessToken;
             NSDate *existingExpiration = [NSDate distantFuture];
             
             [SZFacebookUtils linkWithAccessToken:existingToken expirationDate:existingExpiration success:^(id<SocializeFullUser> user) {
                 NSLog(@"Socialize link successful");
             } failure:^(NSError *error) {
                 NSLog(@"Socialize link failed: %@", [error localizedDescription]);
             }];
         }
     }];
}

-(void)retrieveAll{
    [self sendPageRequest];
    [self sendAlbumsRequest];
    [self sendVideoRequest];
    [self sendEventsRequest];
    [self sendFeedRequest];
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
                              
                              data.info = (NSMutableDictionary *)result;
                              NSDictionary *cover = [data.info objectForKey:@"cover"];
                              
                              EHFPhotoClass *photo = [[EHFPhotoClass alloc]init];
                              photo.fullURL = [cover objectForKey:@"source"];
                              photo.full = [photo getImageFromURL:photo.fullURL];
                              [data.info setObject:photo.full forKey:@"coverPhoto"];
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
                              
                              if(expectedAlbums>0){
                                  [data.albums removeAllObjects];
                              }
                              
                              for (NSDictionary* albumDict in (NSMutableArray*)[result data])
                              {
                                  EHFAlbumClass *newAlbum = [[EHFAlbumClass alloc] init];
                                  [FBRequestConnection startWithGraphPath:[@"/" stringByAppendingString: [albumDict objectForKey:@"cover_photo"]]
                                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                            
                                                            if(error) {
                                                                [self printError: error];
                                                                
                                                                return;
                                                            }
                                                            newAlbum.cover = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@", [(NSDictionary *)result objectForKey:@"picture"]]]]];
                                                            newAlbum.name = [albumDict objectForKey:@"name"];
                                                            newAlbum.albumId = [albumDict objectForKey:@"id"];
                                                            [data.albums addObject:newAlbum];
                                                            
                                                            
                                                            if([data.albums count] == expectedAlbums){
                                                                albumComplete = TRUE;
                                                                [self sendNotification];
                                                            }else{
                                                                albumComplete = TRUE;
                                                                [self sendNotification];
                                                                return;
                                                            }
                                                            
                                                        }];
                                  [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/photos?fields=name,picture,source&limit=1000", [albumDict objectForKey:@"id"]]
                                                        completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                            if(error) {
                                                                [self printError: error];
                                                                
                                                                return;
                                                            }
                                                            
                                                            for (NSDictionary* photoDict in (NSMutableArray*)[result data])
                                                            {
                                                                EHFPhotoClass *newPhoto = [[EHFPhotoClass alloc]init];
                                                                newPhoto.name = @"Photo";
                                                                
                                                                if([photoDict objectForKey:@"name"] !=nil){
                                                                    newPhoto.name = [photoDict objectForKey:@"name"];
                                                                }
                                                                
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
                              
                              if(expectedEvents>0){
                                  [data.events removeAllObjects];
                              }else{
                                  eventComplete = TRUE;
                                  [self sendNotification];
                                  return;
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
                              
                              NSLog(@"You have %d event(s)", [(NSMutableArray*)[result data] count]);
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

-(void)sendFeedRequest{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    [FBRequestConnection startWithGraphPath:[fbID stringByAppendingString:@"/feed?fields=from,message,picture,object_id,type,link&limit=10000"]
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if(error) {
                                  [self printError: error];
                                  feedError = TRUE;
                                  [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                  [self sendNotification];
                                  return;
                              }
                              expectedPosts = 0;
                              for (NSDictionary* postDict in (NSMutableArray*)[result data])
                              {
                                  if ([postDict objectForKey:@"message"] != Nil){
                                      expectedPosts++;
                                  }
                              }
                              
                              if(expectedPosts>0){
                                  [data.posts removeAllObjects];
                              }else{
                                  feedComplete = TRUE;
                                  [self sendNotification];
                                  return;
                              }
                              
                              for (NSDictionary* postDict in (NSMutableArray*)[result data])
                              {
                                  if ([postDict objectForKey:@"message"] != Nil){
                                      EHFPostClass *newPost = [[EHFPostClass alloc]init];
                                      EHFPhotoClass *postPhoto = [[EHFPhotoClass alloc]init];
                                      newPost.message = [postDict objectForKey:@"message"];
                                      newPost.postId = [postDict objectForKey:@"id"];
                                      newPost.created = [postDict objectForKey:@"created_time"];
                                      postPhoto.previewURL = [postDict objectForKey:@"picture"];
                                      postPhoto.photoId = [postDict objectForKey:@"object_id"];
                                      newPost.objectId = [postDict objectForKey:@"object_id"];
                                      newPost.objectType = [postDict objectForKey:@"type"];
                                      newPost.linkURL = [postDict objectForKey:@"link"];
                                      
                                      newPost.photo = postPhoto;
                                      NSDictionary *from = [postDict objectForKey:@"from"];
                                      newPost.name = [from objectForKey:@"name"];
                                      
                                      __block NSInteger expectedComments;
                                      [FBRequestConnection startWithGraphPath:[newPost.postId stringByAppendingString:@"?fields=comments.fields(created_time,message,from)"]
                                                            completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                                                if(error) {
                                                                    
                                                                    return;
                                                                }
                                                                expectedComments = 0;
                                                                
                                                                NSDictionary *comments = [result objectForKey:@"comments"];
                                                                NSArray *data          = [comments objectForKey:@"data"];
                                                                expectedComments = [data count];
                                                                
                                                                if(expectedComments>0){
                                                                    [newPost.comments removeAllObjects];
                                                                    
                                                                }else{
                                                                    
                                                                    return;
                                                                }
                                                                
                                                                
                                                                for (NSDictionary* commentDict in data)
                                                                {
                                                                    if ([commentDict objectForKey:@"message"] != Nil){
                                                                        EHFPostClass *newComment = [[EHFPostClass alloc]init];
                                                                        
                                                                        newComment.message = [commentDict objectForKey:@"message"];
                                                                        newComment.postId = [commentDict objectForKey:@"id"];
                                                                        newComment.created = [commentDict objectForKey:@"created_time"];
                                                                        // newComment.linkURL = [commentDict objectForKey:@"link"];
                                                                        
                                                                        NSDictionary *from = [commentDict objectForKey:@"from"];
                                                                        newComment.name = [from objectForKey:@"name"];
                                                                        
                                                                        [newPost.comments addObject:newComment];
                                                                    }
                                                                }
                                                                
                                                            }];
                                      
                                      [data.posts addObject:newPost];
                                      
                                      if([data.posts count] == expectedPosts){
                                          [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
                                          feedComplete = TRUE;
                                          [self sendNotification];
                                      }
                                  }
                              }
                              NSLog(@"You have %d post(s). Only %d were valid", [(NSMutableArray*)[result data] count],expectedPosts);
                          }];
}

-(void)postComment :(NSString*)message :(NSString*)eid
{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/comments?message=%@",eid,message]
                                 parameters:[NSMutableDictionary dictionaryWithObjectsAndKeys: @"message", message,nil]
                                 HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                     if (error)
                                     {
                                         NSLog(@"error: %@", error.localizedDescription);
                                     }
                                     else
                                     {
                                         NSLog(@"%@",[NSString stringWithFormat:@"Successfully posted: %@ to %@",message,eid]);
                                     }
                                 }];
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
}



-(void)postPhoto :(UIImage*)photo :(NSString*)message
{
    
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    
    FBRequestConnection *connection = [[FBRequestConnection alloc] init];
    
    // First request uploads the photo.
    FBRequest *request1 = [FBRequest
                           requestForUploadPhoto:photo];
    [connection addRequest:request1
         completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
         }
     }
            batchEntryName:@"photopost"
     ];
    
    // Second request retrieves photo information for just-created
    // photo so we can grab its source.
    FBRequest *request2 = [FBRequest
                           requestForGraphPath:@"{result=photopost:$.id}"];
    [connection addRequest:request2
         completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error &&
             result) {
             [self postOnWall:[result objectForKey:@"source"] :message];
         }
     }
     ];
    
    [connection start];
    
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
}

-(void)postOnWall :(NSString *)url :(NSString*)message
{
    
    [FBSession.activeSession requestNewPublishPermissions:@[@"publish_stream"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session,
                                                            NSError *error) {
                                            // Handle new permissions callback
                                        }];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc]init];
    [params setObject:message forKey:@"message"];
    [params setObject:[NSString stringWithFormat:@"Posted using the %@ iPhone App",[data.info objectForKey:@"name"]] forKey:@"description"];
    [params setObject:[data.info objectForKey:@"id"] forKey:@"place"];
    [params setObject:[data.info objectForKey:@"name"] forKey:@"name"];
    [params setObject:[data.info objectForKey:@"name"] forKey:@"caption"];
    
    if (url !=nil){
        [params setObject:url forKey:@"link"];
    }
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/feed",fbID]
                                 parameters:params
                                 HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                     if (error)
                                     {
                                         NSLog(@"error: %@", error);
                                     }
                                     else
                                     {
                                         NSLog(@"%@",[NSString stringWithFormat:@"Successfully posted: %@ to %@",[result objectForKey:@"id"],fbID]);
                                     }
                                 }];
}


-(void)postLike :(NSString*)eid
{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/likes",eid]
                                 parameters:[NSMutableDictionary dictionary]
                                 HTTPMethod:@"POST" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                     if (error)
                                     {
                                         NSLog(@"error: %@", error.localizedDescription);
                                     }
                                     else
                                     {
                                         NSLog(@"%@",[NSString stringWithFormat:@"Successfully liked: %@",eid]);
                                     }
                                 }];
    
    
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
}

-(void)postUnlike :(NSString*)eid
{
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:YES];
    
    [FBRequestConnection startWithGraphPath:[NSString stringWithFormat:@"%@/likes",eid]
                                 parameters:[NSMutableDictionary dictionary]
                                 HTTPMethod:@"DELTE"
                          completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                              if (error)
                              {
                                  NSLog(@"error: %@", error.localizedDescription);
                              }
                              else
                              {
                                  NSLog(@"%@",[NSString stringWithFormat:@"Successfully unliked: %@",eid]);
                              }
                          }];
    
    [(EHFAppDelegate *)[[UIApplication sharedApplication] delegate] setNetworkActivityIndicatorVisible:NO];
}

-(void)sendNotification{
    NSDictionary *dataDict = [[NSMutableDictionary alloc] init];
    [dataDict setValue:[NSNumber numberWithBool:pageComplete] forKey:@"pageComplete"];
    [dataDict setValue:[NSNumber numberWithBool:albumComplete] forKey:@"albumComplete"];
    [dataDict setValue:[NSNumber numberWithBool:eventComplete] forKey:@"eventComplete"];
    [dataDict setValue:[NSNumber numberWithBool:videoComplete] forKey:@"videoComplete"];
    [dataDict setValue:[NSNumber numberWithBool:feedComplete] forKey:@"feedComplete"];
    
    [dataDict setValue:[NSNumber numberWithBool:pageError] forKey:@"pageError"];
    [dataDict setValue:[NSNumber numberWithBool:albumError] forKey:@"albumError"];
    [dataDict setValue:[NSNumber numberWithBool:eventError] forKey:@"eventError"];
    [dataDict setValue:[NSNumber numberWithBool:videoError] forKey:@"videoError"];
    [dataDict setValue:[NSNumber numberWithBool:feedError] forKey:@"feedError"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"FBComplete" object:self userInfo:dataDict];
}

@end