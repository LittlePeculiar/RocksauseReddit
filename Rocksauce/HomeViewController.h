//
//  HomeViewController.h
//  Rocksauce
//
//  Created by Gina Mullins on 4/4/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "ServerManager.h"

@interface HomeViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, MFMailComposeViewControllerDelegate, MFMessageComposeViewControllerDelegate, UIGestureRecognizerDelegate, DownloadCompleteDelegate>

@property (nonatomic, weak) IBOutlet UITableView *listTable;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UIView *backgroundView;
@property (nonatomic, weak) IBOutlet UIView *sharePanel;

- (IBAction)shareEmail:(id)sender;
- (IBAction)shareSMS:(id)sender;
- (IBAction)closePanel:(id)sender;

@end
