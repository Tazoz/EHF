//
//  EHFMenu.h
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EHFMenu : UICollectionViewController<UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) IBOutlet UICollectionView *MenuCollectionView;

@end
