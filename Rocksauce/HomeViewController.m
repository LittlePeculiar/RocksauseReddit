//
//  HomeViewController.m
//  Rocksauce
//
//  Created by Gina Mullins on 4/4/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import "HomeViewController.h"
#import "RedditData.h"
#import "CustomCell.h"
#import "Utils.h"
#import "ReachabilityManager.h"

NSString * const REUSE_CUSTOMCELL_ID = @"CustomCell";

@interface HomeViewController ()

@property (nonatomic, strong) ServerManager *serverManager;
@property (nonatomic, strong) RedditData *selectedData;
@property (nonatomic, strong) UIRefreshControl  *refreshControl;
@property (nonatomic, strong) NSMutableArray *listArray;
@property (nonatomic, strong) NSString *searchStr;
@property (nonatomic, assign) CGPoint touchPoint;

@end

@implementation HomeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [ReachabilityManager sharedManager];
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set status bar to white and searchBar background to black
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.searchBar.barTintColor = [UIColor blackColor];
    
    // hide the sharePanel until user opens it
    self.backgroundView.hidden = YES;
    self.sharePanel.hidden = YES;
    
    // init
    if (self.listArray == nil)
        self.listArray = [[NSMutableArray alloc] init];
    
    if (self.serverManager == nil)
    {
        self.serverManager = [[ServerManager alloc] init];
        self.serverManager.delegate = self;
    }
    
    // for faster and more efficient table loading
    UINib *tableCellNib = [UINib nibWithNibName:REUSE_CUSTOMCELL_ID bundle:[NSBundle bundleForClass:[CustomCell class]]];
    [self.listTable registerNib:tableCellNib forCellReuseIdentifier:REUSE_CUSTOMCELL_ID];
    
    // add a refresh control for quick table reloading
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(downloadData) forControlEvents:UIControlEventValueChanged];
    [self.listTable addSubview:self.refreshControl];
    
    // prepare the dim background with a tap to dismiss it
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closePanel:)];
    tapGesture.delegate = self;
    [self.backgroundView addGestureRecognizer:tapGesture];
    
    // initial search
    self.searchStr = @"funny";
    self.searchBar.placeholder = self.searchStr;
    [self downloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    self.listTable = nil;
    self.searchBar = nil;
    self.sharePanel = nil;
    self.backgroundView = nil;
    self.serverManager = nil;
    self.selectedData = nil;
    self.listArray = nil;
    self.searchStr = nil;
    self.refreshControl = nil;
}


- (void)downloadData
{
    [self.searchBar resignFirstResponder];
    [self.refreshControl endRefreshing];
    
    [self.serverManager refreshDataWithSearch:self.searchStr];
}

- (void)showShareView
{
    // un-hide the share panel
    [self.searchBar resignFirstResponder];
    [self dimBackground];
    self.sharePanel.frame = CGRectMake(self.touchPoint.x, self.touchPoint.y, 283, 200);
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.sharePanel.frame = CGRectMake(20, 185, 283, 200);
                     }
                     completion:^(BOOL finished) {
                         
                     }];
    self.sharePanel.hidden = NO;
}

- (IBAction)closePanel:(id)sender
{
    // move it out of the way and hide
    [UIView animateWithDuration:0.3
                          delay:0.5
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.sharePanel.frame = CGRectMake(self.touchPoint.x, self.touchPoint.y, 283, 200);
                     }
                     completion:^(BOOL finished) {
                         if (finished)
                         {
                             self.sharePanel.hidden = YES;
                             [self dismissDimBackground];
                         }
                     }];
}

- (IBAction)shareEmail:(id)sender
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        
        NSString *emailTitle = @"check out this epic article";
        [mc setSubject:emailTitle];
        [mc setMessageBody:self.selectedData.title isHTML:NO];
        
        // add a photo, if we have one
        if (self.selectedData.isPhotoDownloaded)
        {
            NSData *photoData = UIImageJPEGRepresentation(self.selectedData.thumbnail, .75);
            [mc addAttachmentData:photoData mimeType:@"image/jpeg" fileName:@"photo"];
        }
        
        [self.navigationController presentViewController:mc animated:YES completion:nil];
    }
    else
    {
        UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:@"Unable to send email from this device"
                                                          message:nil
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [myAlert show];
    }
}

- (IBAction)shareSMS:(id)sender
{
    if ([MFMessageComposeViewController canSendText])
    {
        MFMessageComposeViewController *mc = [[MFMessageComposeViewController alloc] init];
        mc.messageComposeDelegate = self;
        
        NSString *textTitle = @"check out this epic article";
        [mc setSubject:textTitle];
        [mc setBody:self.selectedData.title];
        
        [self.navigationController presentViewController:mc animated:YES completion:nil];
    }
    else
    {
        UIAlertView* myAlert = [[UIAlertView alloc] initWithTitle:@"Unable to send text messages from this device"
                                                          message:nil
                                                         delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
        [myAlert show];
    }
}

- (void)dimBackground
{
    self.backgroundView.hidden = NO;
}

- (void)dismissDimBackground
{
    self.backgroundView.hidden = YES;
}


#pragma mark = ServerManager delegate

- (void)downloadComplete:(NSArray*)JSONList
{
    // data retrieved from Reddit - reload table if any
    [self.listArray removeAllObjects];
    self.listArray = [NSMutableArray arrayWithArray:JSONList];
    if ([self.listArray count] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc]
                              initWithTitle:@"No Results Found"
                              message:@"Please try your search again"
                              delegate:self
                              cancelButtonTitle:@"OK"
                              otherButtonTitles:nil, nil];
        [alert show];
    }
    else
        [self.listTable reloadData];
}


#pragma mark - Search Bar and Display

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    // send a new search request
    self.searchStr = self.searchBar.text;
    self.searchBar.placeholder = self.searchStr;
    [self downloadData];
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
    return [self.listArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CustomCell *cell = [tableView dequeueReusableCellWithIdentifier:REUSE_CUSTOMCELL_ID];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [self configureCustomCell:(CustomCell*)cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (void)configureCustomCell:(CustomCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    RedditData *data = [self.listArray objectAtIndex:indexPath.row];
    cell.cellAuthor.text = [NSString stringWithFormat:@"@%@", data.author];
    cell.cellTitle.text = data.title;
    
    // use custom font for author
    [cell.cellAuthor setFont:[UIFont fontWithName:@"BebasNeue" size:24]];
    
    // dynamically calculate label for title
    CGSize size = [[Utils sharedManager] stringSizeForLabelCell:data.title];
    [cell.cellTitle setFont:[UIFont systemFontOfSize:15]];
    [cell.cellTitle setNumberOfLines:0];       // unlimited
    [cell.cellTitle setFrame:CGRectMake(95, 35, 200, size.height+60)];
    [cell.cellTitle setTextAlignment:NSTextAlignmentLeft];
    
    // get the image
    id object = data.thumbnailStr;
    if (object == [NSNull null] || [data.thumbnailStr length] == 0)
    {
        // nothing found - will use a placeholder image
        cell.cellImage.image = [UIImage imageNamed:@"placeholder.png"];
        data.thumbnail = cell.cellImage.image;
        data.isPhotoDownloaded = NO;
    }
    else
    {
        if (data.thumbnail == nil)
        {
            // don't have this one yet, need to download
            [self.serverManager retrieveImage:data.thumbnailStr withCompletionBlock:^(BOOL succeeded, UIImage *image) {
                if (succeeded)
                {
                    // all good, use the downloaded image
                    cell.cellImage.image = image;
                    data.thumbnail = cell.cellImage.image;
                    data.isPhotoDownloaded = YES;
                }
                else
                {
                    // bad image or download failure
                    cell.cellImage.image = [UIImage imageNamed:@"placeholder.png"];
                    data.thumbnail = cell.cellImage.image;
                    data.isPhotoDownloaded = NO;
                }
            }];
        }
        else
        {
            // use the one we already have
            cell.cellImage.image = data.thumbnail;
        }
    }
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedData = [self.listArray objectAtIndex:indexPath.row];
    
    if ([tableView.indexPathsForVisibleRows containsObject:indexPath])
    {
        // get the cell position - close enough
        // The contentOffset property is always the current location of the top-left corner
        CustomCell *cell = (CustomCell*)[self.listTable cellForRowAtIndexPath:indexPath];
        CGFloat relativeX = cell.frame.origin.x - self.listTable.contentOffset.x + cell.frame.size.width;
        CGFloat relativeY = cell.frame.origin.y - self.listTable.contentOffset.y - cell.frame.size.height+100;
        self.touchPoint = CGPointMake(relativeX, relativeY);
        NSLog(@"%f / %f / %f", cell.frame.origin.y, self.listTable.contentOffset.y, cell.frame.size.height+100);
    }
    
    [self showShareView];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // title + author + padding
    RedditData *data = [self.listArray objectAtIndex:indexPath.row];
    CGSize size = [[Utils sharedManager] stringSizeForLabelCell:data.title];
    
    return size.height + 100;
}


#pragma mark - message delegates

// Dismiss email composer UI on cancel / send
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail Cancelled");
            break;
            
        case MFMailComposeResultSaved:
            NSLog(@"Mail Saved");
            break;
            
        case MFMailComposeResultSent:
            NSLog(@"Mail Sent");
            break;
            
        case MFMailComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc]
                                         initWithTitle:@"Error"
                                         message:@"Failed to Send Email!"
                                         delegate:nil
                                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        default:
            break;
    }
    
    [self becomeFirstResponder];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult) result
{
    switch (result)
    {
        case MessageComposeResultCancelled:
            NSLog(@"Message Cancelled");
            break;
            
        case MessageComposeResultSent:
            NSLog(@"Message Sent");
            break;
            
        case MessageComposeResultFailed:
        {
            UIAlertView *warningAlert = [[UIAlertView alloc]
                                         initWithTitle:@"Error"
                                         message:@"Failed to send SMS!"
                                         delegate:nil
                                         cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [warningAlert show];
            break;
        }
            
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
