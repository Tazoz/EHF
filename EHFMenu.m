//
//  EHFMenu.m
//  EHF
//
//  Created by Tass Grigoriou on 20/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFMenu.h"
#import "EHFMenuItem.h"
#import "EHFDataStore.h"
#import <Socialize/Socialize.h>

@interface EHFMenu ()
{
    NSArray *arrayOfImages;
    NSArray *arrayOfTitles;
    NSArray *arrayOfSegues;
}

@end

@implementation EHFMenu

EHFDataStore *data;

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
     data=[EHFDataStore getInstance];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    // [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"Logo.jpg"] forBarMetrics:UIBarMetricsDefault];
    
    [[self MenuCollectionView]setDataSource:self];
    [[self MenuCollectionView]setDelegate:self];
    
    arrayOfImages = [[NSArray alloc]initWithObjects:@"about.png", @"events.png", @"photos.png", @"store.png", @"videos.png", @"feed.png", @"chat.png", @"contact.png", nil];
    arrayOfTitles = [[NSArray alloc]initWithObjects:@"About Us", @"Events", @"Photos", @"Store", @"Videos", @"Social Feed", @"Live Comments", @"Contact Us", nil];
    arrayOfSegues = [[NSArray alloc]initWithObjects:@"aboutSegue", @"eventsSegue", @"albumListSegue", @"storeSegue", @"videoSegue", @"feedSegue", @"chatSegue", @"contactSegue", nil];
    
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
    
    if (indexPath.row == 6)
    {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreate:) name:SZDidCreateObjectsNotification object:nil];
        SZEntity *entity = [SZEntity entityWithKey:@"EHFChat" name:[NSString stringWithFormat:@"%@ Chat",[data.info objectForKey:@"name"]]];
        [SZCommentUtils showCommentsListWithViewController:self entity:entity completion:nil];
        SZShareOptions *options = [SZShareUtils userShareOptions];
        
        options.dontShareLocation = YES;
        
        
    }else{
        [self performSegueWithIdentifier:segue sender:self];
    }
}

- (void)didCreate:(NSNotification*)notification {
    NSArray *comments = [[notification userInfo] objectForKey:kSZCreatedObjectsKey];
    id<SZComment> comment = [comments lastObject];
    if ([comment conformsToProtocol:@protocol(SZComment)]) {
         SZEntity *entity = [SZEntity entityWithKey:@"EHFChat" name:[NSString stringWithFormat:@"%@ Chat",[data.info objectForKey:@"name"]]];
        [SZCommentUtils getCommentsByEntity:entity success:^(NSArray *comments) {
            NSLog(@"Fetched comments: %@", comments);
        } failure:^(NSError *error) {
            NSLog(@"Failed: %@", [error localizedDescription]);
        }];
    }
}

@end
