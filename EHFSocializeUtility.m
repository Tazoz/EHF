//
//  EHFSocializeUtility.m
//  EHF
//
//  Created by Tass Grigoriou on 13/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFSocializeUtility.h"

@implementation EHFSocializeUtility

@synthesize library;

NSInteger commentId;
NSInteger likeId;

NSString *fbid;

EHFFacebookUtility *fu;

-(id)generateActionBar:(NSString*)key :(NSString*)name :(NSString*)type :(id)object :(UIViewController*)sender
{
    fu = [[EHFFacebookUtility alloc]init];
    
    [SZEntityUtils getEntityWithKey:key success:^(id<SZEntity> entity) {
        NSLog(@"Retrieved entity %@", key);
        fbid = [key stringByReplacingOccurrencesOfString:@"[^0-9_]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0,[key length])];
        self.entity = entity;
    } failure:^(NSError *error) {
        NSLog(@"Failure: %@", [error localizedDescription]);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreate:) name:SZDidCreateObjectsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDelete:) name:SZDidDeleteObjectsNotification object:nil];
    
    if (self.actionBar == nil) {
        
        EHFDataStore *data;
        data=[EHFDataStore getInstance];
        
        self.entity = [SZEntity entityWithKey:key name:name];
        
        if (self.likeButton == nil)
        {
            self.likeButton = [[SZLikeButton alloc] initWithFrame:CGRectMake(120, 30, 0, 0) entity:self.entity viewController:sender];
            
            self.actionBar = [SZActionBar defaultActionBarWithFrame:CGRectNull entity:self.entity viewController:sender];
            
            SZActionButton *shareButton = [SZActionButton actionButtonWithIcon:[UIImage imageNamed:@"action-bar-icon-share.png"] title:@"Share"];
            shareButton.actionBlock = ^(SZActionButton *button, SZActionBar *bar) {
                
                SZShareOptions *options = [SZShareUtils userShareOptions];
                
                options.dontShareLocation = YES;
                
                options.willShowSMSComposerBlock = ^(SZSMSShareData *smsData) {
                    NSLog(@"Sharing SMS");
                };
                
                options.willShowEmailComposerBlock = ^(SZEmailShareData *emailData) {
                    NSLog(@"Sharing Email");
                };
                
                options.willRedirectToPinterestBlock = ^(SZPinterestShareData *pinData)
                {
                    NSLog(@"Sharing pin");
                };
                
                options.willAttemptPostingToSocialNetworkBlock = ^(SZSocialNetwork network, SZSocialNetworkPostData *postData) {
                    if (network == SZSocialNetworkTwitter) {
                        NSString *entityURL = [[postData.propagationInfo objectForKey:@"twitter"] objectForKey:@"entity_url"];
                        NSString *displayName = [postData.entity displayName];
                        SZShareOptions *shareOptions = (SZShareOptions*)postData.options;
                        NSString *text = shareOptions.text;
                        
                        NSString *customStatus = [NSString stringWithFormat:@"%@ / %@ with url %@", text, displayName, entityURL];
                        
                        [postData.params setObject:customStatus forKey:@"status"];
                        
                    } else if (network == SZSocialNetworkFacebook) {
                        
                        if ([type isEqualToString:@"event"])
                        {
                            [postData.params setObject:[NSString stringWithFormat:@"https://www.facebook.com/events/%@",fbid] forKey:@"link"];
                        }else{
                            [postData.params setObject:[NSString stringWithFormat:@"https://www.facebook.com/photo.php?fbid=%@",fbid] forKey:@"link"];
                        }
                    }
                };
                
                options.didSucceedPostingToSocialNetworkBlock = ^(SZSocialNetwork network, id result) {
                    NSLog(@"Posted %@", fbid);
                };
                
                options.didFailPostingToSocialNetworkBlock = ^(SZSocialNetwork network, NSError *error) {
                    NSLog(@"Failed posting to %d", network);
                };
                
                [SZShareUtils showShareDialogWithViewController:sender options:options entity:self.entity completion:^(NSArray *shares) {
                    NSLog(@"Created %d shares", [shares count]);
                } cancellation:^{
                    NSLog(@"Share creation cancelled");
                }];
            };
            
            if(![type isEqualToString:@"event"])
            {
                SZActionButton *downloadButton = [SZActionButton actionButtonWithIcon:nil title:@"Download"];
                downloadButton.actionBlock = ^(SZActionButton *button, SZActionBar *bar) {
                    EHFPhotoClass *photo;
                    
                    if ([type isEqualToString:@"photo"])
                    {
                        photo = object;
                    }else{
                        EHFPostClass *post = object;
                        photo = post.photo;
                    }
                    
                    library = [[ALAssetsLibrary alloc] init];
                    
                    [library writeImageToSavedPhotosAlbum:photo.full.CGImage orientation:(ALAssetOrientation)photo.full.imageOrientation
                                          completionBlock:^(NSURL* assetURL, NSError* error) {
                                              
                                              if (error!=nil) {
                                                  NSLog(@"Failed to save photo:\nError: %@", [error localizedDescription]);
                                                  return;
                                              }else{
                                                  
                                                  [library addAssetsGroupAlbumWithName:[data.info objectForKey:@"name"]
                                                                           resultBlock:^(ALAssetsGroup *group) {
                                                                               
                                                                           }
                                                                          failureBlock:^(NSError* error) {
                                                                              NSLog(@"Failed to create album:\nError: %@", [error localizedDescription]);
                                                                          }];
                                                  
                                                  __block ALAssetsGroup* groupToAddTo;
                                                  [library enumerateGroupsWithTypes:ALAssetsGroupAlbum
                                                                         usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                                                                             if ([[group valueForProperty:ALAssetsGroupPropertyName] isEqualToString:[data.info objectForKey:@"name"]]) {
                                                                                 NSLog(@"Found album %@", [data.info objectForKey:@"name"]);
                                                                                 groupToAddTo = group;
                                                                                 
                                                                                 [library assetForURL:assetURL
                                                                                          resultBlock:^(ALAsset *asset) {
                                                                                              // assign the photo to the album
                                                                                              [groupToAddTo addAsset:asset];
                                                                                              NSLog(@"Added %@ to %@", [[asset defaultRepresentation] filename], [data.info objectForKey:@"name"]);
                                                                                              //[downloadButton setTitle:@"Downloaded"];
                                                                                              UIAlertView *alert;
                                                                                              
                                                                                              alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"%@ downloaded to the %@ album",[[asset defaultRepresentation] filename], [data.info objectForKey:@"name"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                                                                                              [alert show];
                                                                                          }
                                                                                         failureBlock:^(NSError* error) {
                                                                                             NSLog(@"Failed to retrieve image asset:\nError: %@ ", [error localizedDescription]);
                                                                                         }];
                                                                             }
                                                                         }
                                                                       failureBlock:^(NSError* error) {
                                                                           NSLog(@"Failed to enumerate albums:\nError: %@", [error localizedDescription]);
                                                                       }];
                                              };
                                          }];
                };
                self.actionBar.itemsRight = [NSArray arrayWithObjects:downloadButton, self.likeButton, [SZActionButton commentButton], shareButton, nil];
            }else{
                self.actionBar.itemsRight = [NSArray arrayWithObjects:self.likeButton, [SZActionButton commentButton], shareButton, nil];
            }
            self.actionBar.itemsLeft = [NSArray arrayWithObjects:[SZActionButton viewsButton], nil];
        }
    }
    return self.actionBar;
}

- (void)didCreate:(NSNotification*)notification {
    NSMutableArray *objects = [[notification userInfo] objectForKey:kSZCreatedObjectsKey];
    id<SZComment> comment = [objects lastObject];
    id<SZLike> like = [objects lastObject];
    
    if ([comment conformsToProtocol:@protocol(SZComment)]) {
        NSLog(@"Commented on %@", [comment.entity key]);
        if([comment objectID] != commentId)
        {
            [fu postComment:[comment text] :fbid];
            commentId = [comment objectID];
        }
    }else{
        if ([like conformsToProtocol:@protocol(SZLike)]) {
            if([like objectID] != likeId)
                NSLog(@"Liking entity %@", [self.entity key]);
            [fu postLike :fbid];
            self.likeButton.entity = self.entity;
            likeId = [like objectID];
        }
    }
}

- (void)didDelete:(NSNotification*)notification {
    if([[[self.entity key] stringByReplacingOccurrencesOfString:@"[^0-9]" withString:@"" options:NSRegularExpressionSearch range:NSMakeRange(0, [[self.entity key] length])] intValue] == likeId){
        [fu postUnlike :fbid];
    }
}
@end
