//
//  MazaikaModel.h
//  photo
//
//  Created by Иван Ушаков on 24.11.12.
//  Copyright (c) 2012 Иван Ушаков. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MazaikaModel : NSObject
- (NSArray*)stringsForMazaikaPossableColor;
- (NSArray*)colorsFromImage:(UIImage*)image withPixelCount:(NSInteger)pixelCount;
@end
