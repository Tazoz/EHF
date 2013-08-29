//
//  EHFContact.h
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHFContact : UIViewController

@property (weak, nonatomic) IBOutlet UIView *subview; 

@property (weak, nonatomic) IBOutlet UILabel *txtName;
@property (weak, nonatomic) IBOutlet UITextView *txtAddress;
@property (weak, nonatomic) IBOutlet UITextView *txtPhone;
@property (weak, nonatomic) IBOutlet UITextView *txtWebsite;
@end
