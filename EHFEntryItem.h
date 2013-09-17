//
//  EHFEntryItem.h
//  EHF
//
//  Created by Tass Grigoriou on 3/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHFEntryItem : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *primaryDetail;
@property (weak, nonatomic) IBOutlet UILabel *secondaryDetail;

@end
