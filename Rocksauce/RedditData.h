//
//  RedditData.h
//  Rocksauce
//
//  Created by Gina Mullins on 4/5/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RedditData : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *author;
@property (nonatomic, strong) NSString *thumbnailStr;
@property (nonatomic, strong) UIImage *thumbnail;
@property (nonatomic, readwrite) BOOL isPhotoDownloaded;

- (id)initWithData:(NSString*)title
            author:(NSString*)author
      thumbnailStr:(NSString*)thumbnailStr
         thumbnail:(UIImage*)thumbnail
 isPhotoDownloaded:(BOOL)isPhotoDownloaded;

@end
