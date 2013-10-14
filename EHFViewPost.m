//
//  EHFViewPost.m
//  EHF
//
//  Created by Tass Grigoriou on 24/09/13.
//  Copyright (c) 2013 s3147575. All rights reserved.
//

#import "EHFViewPost.h"
#import "EHFEntryItem.h"
#import "EHFMessageCell.h"
#import "EHFViewPhoto.h"
#import "Reachability.h"
#import "EHFFacebookUtility.h"
#import <Socialize/Socialize.h>

@interface EHFViewPost ()

@end

@implementation EHFViewPost

@synthesize post;
@synthesize eid;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.eid = [NSString stringWithFormat:@"fbPhoto%@", post.photo.photoId];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
        return [self.post.comments count]+3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0)
    {
        EHFEntryItem *cell = [tableView dequeueReusableCellWithIdentifier:@"PostDetails"];
        if (cell == nil)
        {
            cell = [[EHFEntryItem alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PostDetails"];
        }
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH:mm:ssZ"];
        NSDate *date = [dateFormat dateFromString:self.post.created];
        [dateFormat setDateFormat:@"dd MMM 'at' HH:mm"];
        
        cell.title.text = self.post.name;
        cell.primaryDetail.text = [NSString stringWithFormat:@"%@", [dateFormat stringFromDate:date]];
        cell.secondaryDetail.text = @"";
        return cell;
    }else if(indexPath.row == 1) {
        EHFMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PostMessage"];
        if (cell == nil)
        {
            cell = [[EHFMessageCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"PostMessage"];
        }
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 88)];
        lbl.backgroundColor = [UIColor blackColor];
        lbl.textColor = [UIColor whiteColor];
        [cell addSubview:lbl];
        
        lbl.text = self.post.message;
        lbl.numberOfLines = 0;
        lbl.preferredMaxLayoutWidth = 280;
        
        [lbl sizeToFit];
        return cell;
        
    }else if(indexPath.row == 2) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        
        if (post.photo != nil)
        {
            UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 300, 58)];
            av.backgroundColor = [UIColor clearColor];
            av.opaque = NO;
            av.image = self.post.photo.preview;
            cell.backgroundView = av;
        }
        return cell;
        
    }else{
        EHFEntryItem *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentDetails"];
        if (cell == nil)
        {
            cell = [[EHFEntryItem alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CommentDetails"];
        }
        
        EHFPostClass *comment = [self.post.comments objectAtIndex:indexPath.row - 3];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH:mm:ssZ"];
        NSDate *date = [dateFormat dateFromString:comment.created];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];;
        [formatter setDateFormat:@"dd MMM 'at' HH:mm"];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 280, 88)];
        lbl.backgroundColor = [UIColor blackColor];
        lbl.textColor = [UIColor whiteColor];
        [cell addSubview:lbl];
        
        lbl.text = comment.message;
        lbl.numberOfLines = 0;
        lbl.preferredMaxLayoutWidth = 280;
        
        [lbl sizeToFit];
        
        cell.primaryDetail.text = comment.name;
        cell.secondaryDetail.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
        tableView.separatorColor = [UIColor whiteColor];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = tableView.rowHeight;
    if (indexPath.row == 1 )
    {
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 88)];
        lbl.text = self.post.message;
        lbl.numberOfLines = 0;
        lbl.preferredMaxLayoutWidth = 280;
        CGRect labelFrame = lbl.frame;
        labelFrame.size = [lbl.text sizeWithFont:lbl.font
                               constrainedToSize:CGSizeMake(lbl.frame.size.width, CGFLOAT_MAX)
                                   lineBreakMode:lbl.lineBreakMode];
        height = labelFrame.size.height +10;
    }else if(indexPath.row==2)
    {
        if (self.post.photo.preview == nil)
        {
            height = 1;
        }else{
            height = 350;
        }
    }else if(indexPath.row > 2)
    {
        EHFPostClass *comment = [self.post.comments objectAtIndex:indexPath.row - 3];
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 88)];
        lbl.text = comment.message;
        lbl.numberOfLines = 0;
        lbl.preferredMaxLayoutWidth = 280;
        CGRect labelFrame = lbl.frame;
        labelFrame.size = [lbl.text sizeWithFont:lbl.font
                               constrainedToSize:CGSizeMake(lbl.frame.size.width, CGFLOAT_MAX)
                                   lineBreakMode:lbl.lineBreakMode];
        height = labelFrame.size.height +50;
    }
    return height;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row ==2)
    {
        if ([[Reachability reachabilityForInternetConnection] currentReachabilityStatus] == NotReachable) {
            UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"No Internet Connection"
                                                              message:@"\nNo network connection to access photo."
                                                             delegate:self
                                                    cancelButtonTitle:@"Back" otherButtonTitles:nil];
            [myAlert show];
        } else {
            UIAlertView *alert;
            
            alert = [[UIAlertView alloc] initWithTitle:@"Enlarging Photo" message:@"Please Wait..." delegate:self cancelButtonTitle:nil otherButtonTitles: nil];
            [alert show];
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
            indicator.center = CGPointMake(alert.bounds.size.width / 2, alert.bounds.size.height - 50);
            [indicator startAnimating];
            [alert addSubview:indicator];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                EHFPhotoClass *photo = self.post.photo;
                
                EHFViewPhoto *photoView = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoView"];
                photoView.photo = photo;
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [alert dismissWithClickedButtonIndex:0 animated:YES];
                    [self.navigationController pushViewController:photoView animated:YES];
                });
            });
        }
    }else if(indexPath.row >2)
    {
        EHFPostClass *comment = [self.post.comments objectAtIndex:indexPath.row -3];
        EHFViewPost *cv = [self.storyboard instantiateViewControllerWithIdentifier:@"viewPostController"];
        cv.post = comment;
        [self.navigationController pushViewController:cv animated:YES];
    }
}

-(void)postComment:(id)sender
{    
        [SZCommentUtils showCommentComposerWithViewController:self
                                                       entity:[SZEntity
                                                               entityWithKey:self.post.postId
                                                               name:self.post.name]
                                                   completion:^(id<SZComment> comment) {
                                                       EHFFacebookUtility *fu;
                                                       fu = [[EHFFacebookUtility alloc]init];
                                                       [fu postComment:[comment text] :self.post.postId];
            NSLog(@"Created comment: %@", [comment text]);
        } cancellation:^{
            NSLog(@"Cancelled comment create");
        }];
}
@end
