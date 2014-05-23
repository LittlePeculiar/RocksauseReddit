//
//  Utils.m
//  Rocksauce
//
//  Created by Gina Mullins on 4/5/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import "Utils.h"

@implementation Utils


+ (Utils*)sharedManager
{
    static Utils *_sharedManager = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedManager = [[self alloc] init];
    });
    
    return _sharedManager;
}

- (id)init
{
    if ((self = [super init]))
    {
        
    }
    
    return self;
}

- (CGSize)stringSizeForLabelCell:(NSString*)text
{
    CGSize maxSize = CGSizeMake(320, 9999);
    
    CGRect textRect = [text boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]}
                                         context:nil];
    
    return textRect.size;
}

- (UIImage*)dataToPhoto:(NSData*)photoData
{
    @autoreleasepool
    {
        CGSize newSize = CGSizeMake(70, 70);
        UIGraphicsBeginImageContextWithOptions(newSize, NO, 1.0);
        
        [[UIImage imageWithData:photoData] drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
}


@end
