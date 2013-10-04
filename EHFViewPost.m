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
#import "EHFSocializeUtility.h"

@interface EHFViewPost ()

@end

@implementation EHFViewPost

@synthesize post;
@synthesize eid;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.eid = [NSString stringWithFormat:@"fbPhoto%@", post.photo.photoId];
    
    if(post.photo.photoId ==nil){
        self.eid = [NSString stringWithFormat:@"fbPost%@", post.postId];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.post.comments count]+3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(indexPath.row == 0){
        EHFEntryItem *cell = [tableView dequeueReusableCellWithIdentifier:@"PostDetails"];
        if (cell == nil) {
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
        if (cell == nil) {
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
        
        UIImageView *av = [[UIImageView alloc] initWithFrame:CGRectMake(20, 20, 300, 58)];
        av.backgroundColor = [UIColor clearColor];
        av.opaque = NO;
        av.image = self.post.photo.preview;
        cell.backgroundView = av;
        
        //EHFSocializeUtility *su = [[EHFSocializeUtility alloc]init];
        //[cell addSubview:[su generateActionBar:eid :post.message :@"post" :post.linkURL :self]];
        
        return cell;
        
    }else{
        EHFEntryItem *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentDetails"];
        if (cell == nil) {
            cell = [[EHFEntryItem alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"CommentDetails"];
        }
        
        EHFPostClass *comment = [self.post.comments objectAtIndex:indexPath.row - 3];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"yyyy'-'MM'-'dd'T'HH:mm:ssZ"];
        NSDate *date = [dateFormat dateFromString:comment.created];
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];;
        [formatter setDateFormat:@"dd MMM 'at' HH:mm"];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 280, 88)];
        lbl.backgroundColor = [UIColor blackColor];
        lbl.textColor = [UIColor whiteColor];
        [cell addSubview:lbl];
        
        lbl.text = comment.message;
        lbl.numberOfLines = 0;
        lbl.preferredMaxLayoutWidth = 280;
        
        [lbl sizeToFit];

        cell.primaryDetail.text = comment.name;
        cell.secondaryDetail.text = [NSString stringWithFormat:@"%@", [formatter stringFromDate:date]];
        
        return cell;
    }
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = tableView.rowHeight;
    if (indexPath.row == 1){
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
        
        
    }
    return height;
}
@end
