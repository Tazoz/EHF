//
//  EHFPost.h
//  EHF
//
//  Created by Tass Grigoriou on 3/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHFPostClass.h"
#import "EHFEntryItem.h"
#import "EHFPhotoClass.h"
#import "EHFVideoClass.h"
#import <MediaPlayer/MediaPlayer.h>

@interface EHFPost : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UITextView *postText;
@property (weak, nonatomic) IBOutlet UITableView *replies;
@property (weak, nonatomic) IBOutlet EHFPostClass *post;
@property (weak, nonatomic) NSString *eid;

@property (nonatomic,strong) MPMoviePlayerController *myPlayer;

@end
