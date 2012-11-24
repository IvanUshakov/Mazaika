//
//  NetworkModel.h
//  photo
//
//  Created by Иван Ушаков on 24.11.12.
//  Copyright (c) 2012 Иван Ушаков. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkModel : NSObject
+ (void)startSearchingWithSearchTerm:(NSString*)searchTerm
                               color:(NSString*)color
                               count:(NSInteger)count
                             success:(void (^)(NSArray *imagesUrls))success
                             failure:(void (^)(NSError *error))failure;
+ (void)startLoadImageWithURL:(NSURL*)url success:(void (^)(UIImage *image))success failure:(void (^)(NSError *error))failure;
+ (void)stopAllConnections;
@end
