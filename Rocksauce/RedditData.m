//
//  RedditData.m
//  Rocksauce
//
//  Created by Gina Mullins on 4/5/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import "RedditData.h"

@implementation RedditData


- (id)initWithData:(NSString*)title
            author:(NSString*)author
      thumbnailStr:(NSString*)thumbnailStr
         thumbnail:(UIImage*)thumbnail
 isPhotoDownloaded:(BOOL)isPhotoDownloaded
{
    if ((self = [super init]))
    {
        self.title = title;
        self.author = author;
        self.thumbnailStr = thumbnailStr;
        self.thumbnail = thumbnail;
        self.isPhotoDownloaded = isPhotoDownloaded;
    }
    return self;
}

- (void)dealloc
{
    self.title = nil;
    self.author = nil;
    self.thumbnailStr = nil;
    self.thumbnail = nil;
}

@end
