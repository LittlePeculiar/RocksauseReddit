//
//  ServerManager.h
//  Rocksauce
//
//  Created by Gina Mullins on 4/5/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DownloadCompleteDelegate <NSObject>
- (void)downloadComplete:(NSArray*)JSONList;
@end

@interface ServerManager : NSObject

@property (nonatomic, strong) id <DownloadCompleteDelegate> delegate;

+ (ServerManager*)shareManager;
- (void)refreshDataWithSearch:(NSString*)searchStr;
- (void)retrieveImage:(NSString*)urlString withCompletionBlock:(void (^)(BOOL succeeded, UIImage *image))completed;

@end


