//
//  Utils.h
//  Rocksauce
//
//  Created by Gina Mullins on 4/5/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+ (Utils*)sharedManager;

- (CGSize)stringSizeForLabelCell:(NSString*)text;
- (UIImage*)dataToPhoto:(NSData*)photoData;

@end
