//
//  MazaikaViewController.h
//  photo
//
//  Created by Иван Ушаков on 24.11.12.
//  Copyright (c) 2012 Иван Ушаков. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MazaikaViewController : UIViewController <UIScrollViewDelegate>
- (id)initWithSearchTerm:(NSString*)searchTerm
                   image:(UIImage*)image
               numPixels:(NSInteger)numPixels
        smallImagesCount:(NSInteger)smallImagesCount;
@end
