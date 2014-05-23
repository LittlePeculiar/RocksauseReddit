//
//  CustomCell.h
//  Rocksauce
//
//  Created by Gina Mullins on 4/5/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *cellImage;
@property (nonatomic, weak) IBOutlet UILabel *cellTitle;            // tweet
@property (nonatomic, weak) IBOutlet UILabel *cellAuthor;           // twitter handle

@end
