//
//  NetworkModel.m
//  photo
//
//  Created by Иван Ушаков on 24.11.12.
//  Copyright (c) 2012 Иван Ушаков. All rights reserved.
//

#import "NetworkModel.h"

static NSString *SearchURL = @"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=%d&imgsz=medium&as_filetype=jpg&imgcolor=%@&q=%@";
static NSString *networkModelErrorDomain = @"com.mazaika.networkModel";

typedef enum {
    networkModelErrorCodesCanNotCreateImage = 1,
} networkModelErrorCodes;

@implementation NetworkModel

+ (NSOperationQueue*)networkOperationQueue
{
    static NSOperationQueue *_sharedQueue = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedQueue = [[NSOperationQueue alloc] init];
    });
    return _sharedQueue;
}

+ (void)startSearchingWithSearchTerm:(NSString*)searchTerm
                               color:(NSString*)color
                               count:(NSInteger)count
                             success:(void (^)(NSArray *imagesUrls))success
                             failure:(void (^)(NSError *error))failure
{
    NSString *searchURL = [NSString stringWithFormat:SearchURL, count, color, [searchTerm stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:searchURL]
                                             cachePolicy:NSURLCacheStorageAllowed
                                         timeoutInterval:30.0f];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[self networkOperationQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   dispatch_async(dispatch_get_main_queue(),^{
                                       if (failure) {
                                           failure(error);
                                       }
                                   });
                                   return;
                               }
                               
                               id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               if (error || [json[@"responseStatus"] integerValue] != 200) {
                                   dispatch_async(dispatch_get_main_queue(),^{
                                       if (failure) {
                                           failure(error);
                                       }
                                   });
                                   return;
                               }
                               
                               dispatch_async(dispatch_get_main_queue(),^{
                                   success(json[@"responseData"][@"results"]);
                               });
                           }];
}

+ (void)startLoadImageWithURL:(NSURL*)url success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure
{
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval:30.0f];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[self networkOperationQueue]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                               if (error) {
                                   dispatch_async(dispatch_get_main_queue(),^{
                                       if (failure) {
                                           failure(error);
                                       }
                                   });
                                   return;
                               }
                               
                               UIImage *image = [[UIImage alloc] initWithData:data];
                               if (!image) {
                                   dispatch_async(dispatch_get_main_queue(),^{
                                       if (failure) {
                                           failure([NSError errorWithDomain:networkModelErrorDomain code:networkModelErrorCodesCanNotCreateImage userInfo:nil]);
                                       }
                                   });
                                   return;
                               }
                               
                               dispatch_async(dispatch_get_main_queue(),^{
                                   success(image);
                               });
                           }];
}

+ (void)stopAllConnections
{
    [[self networkOperationQueue] cancelAllOperations];
}
@end
