//
//  EHFMenu.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFMenu.h"
#import "EHFMenuItem.h"

@interface EHFMenu ()
{
    NSArray *arrayOfImages;
    NSArray *arrayOfTitles;
    NSArray *arrayOfSegues;
}

@end

@implementation EHFMenu

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    [[self MenuCollectionView]setDataSource:self];
    [[self MenuCollectionView]setDelegate:self];
    
    arrayOfImages = [[NSArray alloc]initWithObjects:@"about.png", @"events.png", @"photos.png", @"store.png", @"videos.png", @"feed", @"contact.png", nil];
    arrayOfTitles = [[NSArray alloc]initWithObjects:@"About Us", @"Events", @"Photos", @"Store", @"Videos", @"Live Feed", @"Contact Us", nil];
    arrayOfSegues = [[NSArray alloc]initWithObjects:@"aboutSegue", @"eventsSegue", @"albumListSegue", @"storeSegue", @"videoSegue", @"feedSegue", @"contactSegue", nil];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [arrayOfTitles count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"cell";
    EHFMenuItem *mItem = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    [[mItem MenuItemImage]setImage: [UIImage imageNamed:[arrayOfImages objectAtIndex:indexPath.item]]];
    [[mItem MenuItemText]setText:[arrayOfTitles objectAtIndex:indexPath.item]];
    
    return mItem;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = indexPath.row;
    
    NSString *segue = arrayOfSegues[row];
    [self performSegueWithIdentifier:segue sender:self];
}

@end
