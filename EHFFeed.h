//
//  EHFFeed.h
//  EHF
//
//  Created by Tass Grigoriou on 3/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface EHFFeed : UITableViewController <UIActionSheetDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UILabel *noFeed;

-(IBAction)showActionSheet:(id)sender;
@end
