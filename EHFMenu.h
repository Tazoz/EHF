//
//  EHFMenu.h
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Socialize/Socialize.h>

@interface EHFMenu : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate, UIActionSheetDelegate>

@property (strong, nonatomic) IBOutlet UICollectionView *MenuCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end
