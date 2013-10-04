//
//  EHFViewPost.h
//  EHF
//
//  Created by Tass Grigoriou on 24/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EHFPostClass.h"

@interface EHFViewPost : UITableViewController

@property (strong, nonatomic) EHFPostClass *post;
@property (strong, nonatomic) NSString *eid;

@end
