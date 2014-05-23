//
//  ServerManager.m
//  Rocksauce
//
//  Created by Gina Mullins on 4/5/14.
//  Copyright (c) 2014 Gina Mullins. All rights reserved.
//

#import "ServerManager.h"
#import "RedditData.h"
#import "Utils.h"


@implementation ServerManager


+ (ServerManager*)shareManager
{
    static ServerManager *myManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        myManager = [[self alloc] init];
    });
    
    return myManager;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        //
    }
    return self;
}

// download JSON
- (void)refreshDataWithSearch:(NSString*)searchStr
{
    NSMutableArray *results = [[NSMutableArray alloc] init];
    NSString *urlString = [NSString stringWithFormat:@"http://www.reddit.com/r/%@/.json", searchStr];
    NSURL *url = [NSURL URLWithString:urlString];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error)
                               {
                                   NSHTTPURLResponse *httpResp = (NSHTTPURLResponse*) response;
                                   if (httpResp.statusCode == 200)
                                   {
                                       // break down the JSON result
                                       NSError *jsonError;
                                       NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
                                       NSDictionary *jsonData = [jsonDict objectForKey:@"data"];
                                       NSArray *jsonArray = [jsonData objectForKey:@"children"];
                                       
                                       if (!jsonError)
                                       {
                                           for (NSDictionary *json in jsonArray)
                                           {
                                               NSDictionary *value = [json objectForKey:@"data"];
                                               RedditData *data = [[RedditData alloc]
                                                                   initWithData:(NSString*)[value objectForKey:@"title"]
                                                                   author:(NSString*)[value objectForKey:@"author"]
                                                                   thumbnailStr:(NSString*)[value objectForKey:@"thumbnail"]
                                                                   thumbnail:(UIImage*)nil
                                                                   isPhotoDownloaded:(BOOL)NO];
                                               
                                               [results addObject:data];
                                           }
                                           
                                           [self.delegate downloadComplete:results];
                                           
                                           dispatch_async(dispatch_get_main_queue(), ^{
                                               //
                                           });
                                       }
                                   }
                               }
                           }];
}

- (void)retrieveImage:(NSString*)urlString withCompletionBlock:(void (^)(BOOL succeeded, UIImage *image))completed
{
    NSString *encodedUrl = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL *url = [NSURL URLWithString:encodedUrl];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (!error)
                               {
                                   //UIImage *downloadedImage = [UIImage imageWithData:data];
                                   UIImage *downloadedImage = [[Utils sharedManager] dataToPhoto:data];
                                   dispatch_async(dispatch_get_main_queue(), ^{
                                       UIImage *image = downloadedImage;
                                       completed(YES, image);
                                   });
                               }
                               else
                               {
                                   completed(NO, nil);
                               }
                           }];
}


@end
