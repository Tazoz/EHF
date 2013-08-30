//
//  EHFEventList.m
//  EHF
//
//  Created by Tass Grigoriou on 27/08/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFAppDelegate.h"
#import "EHFEventList.h"
#import "EHFDataStore.h"
#import "EHFFacebookUtility.h"
#import "Reachability.h"
#import "EHFEventClass.h"
#import "EHFEvent.h"

@interface EHFEventList ()

@end

@implementation EHFEventList

EHFDataStore *data;
EHFFacebookUtility *fu;
UIRefreshControl *refreshControl;
NSDateFormatter *formatter;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    data=[EHFDataStore getInstance];
    
    if([data.events count] !=0){
        _noEvent.hidden = YES;
    }
    
    refreshControl = [[UIRefreshControl alloc] init];
    formatter = [[NSDateFormatter alloc] init];
    
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Pull to refresh"]];
    [refreshControl addTarget:self action:@selector(refreshEventList) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

-(void)refreshEventList{
    [formatter setDateFormat:@"MMM d, HH:mm"];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"Last updated on %@", [formatter stringFromDate:[NSDate date]]]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadTableValues)
                                                 name:@"FBComplete"
                                               object:nil];
    [fu sendEventsRequest];
}

-(void)reloadTableValues{
    [self.tableView reloadData];
    [refreshControl endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
}

#pragma mark - Table view data source

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [data.events count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
    }
    
    EHFEventClass *event = [data.events objectAtIndex:indexPath.row];
    
    cell.textLabel.text = event.name;
    
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [dateFormat dateFromString:event.start];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd/MM/yyyy, HH:mm"];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
    cell.imageView.image = event.picture;
    
    UIGraphicsBeginImageContext(CGSizeMake(50, 50));
    CGRect imageRect = CGRectMake(0.0, 0.0, 50, 50);
    [cell.imageView.image drawInRect:imageRect];
    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    __block EHFEvent *ec;
    
    EHFEventClass *event = [data.events objectAtIndex:indexPath.row];
    ec = [self.storyboard instantiateViewControllerWithIdentifier:@"eventDetails"];
    ec.event = event;
    [self.navigationController pushViewController:ec animated:YES];
}
@end
