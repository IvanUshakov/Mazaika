//
//  MazaikaModel.m
//  photo
//
//  Created by Иван Ушаков on 24.11.12.
//  Copyright (c) 2012 Иван Ушаков. All rights reserved.
//

#import "MazaikaModel.h"
#import "UIImage+mazaika.h"

const NSInteger MaxValueForBlackColor = 55;
const NSInteger MaxValueForRGBColors = 200;
const NSInteger GrayColorDelta = 22;
const NSInteger OrangeColorDelta = 80;

enum MazaikaPossableColors {
    MazaikaPossableColorsWhite = 0,
    MazaikaPossableColorsBlack = 1,
    MazaikaPossableColorsRed = 2,
    MazaikaPossableColorsGreen = 3,
    MazaikaPossableColorsBlue = 4,
    MazaikaPossableColorsGray = 5,
    MazaikaPossableColorsOrange = 6,
};

@implementation MazaikaModel

- (NSArray*)stringsForMazaikaPossableColor
{
    return @[@"white", @"black", @"red", @"green", @"blue", @"gray", @"orange"];
}

- (NSString*)stringRepresentationFromMazaikaPossableColor:(enum MazaikaPossableColors)color
{
    return [self stringsForMazaikaPossableColor][color];
}

- (NSArray*)colorsFromImage:(UIImage*)image withPixelCount:(NSInteger)pixelCount
{
    CGFloat minSize = MIN(image.size.width, image.size.height);
    CGRect crop = CGRectMake((image.size.width - minSize) / 2.0, (image.size.height - minSize) / 2.0, minSize, minSize);
    image = [image crop:crop];
    image = [image resize:CGSizeMake(pixelCount, pixelCount)];
 
    CGImageRef inImage = image.CGImage;
    
    CGContextRef cgctx = [self createARGBBitmapContextFromImage:inImage];
    CGRect rect = CGRectMake(0.0f, 0.0f, pixelCount, pixelCount);
    CGContextDrawImage(cgctx, rect, inImage);
    unsigned char* data = CGBitmapContextGetData (cgctx);
    
    NSMutableArray *colors = [NSMutableArray array];

    if (data != NULL) {
        for (NSInteger i = 0; i < image.size.width * image.size.height; i++) {
            NSInteger idx = i * 4;
            
            UInt8 red = data[idx + 1];
            UInt8 green = data[idx + 2];
            UInt8 blue = data[idx + 3];
                        
            NSInteger sred = red / 3 + green / 3 + blue / 3;
            
            enum MazaikaPossableColors color = MazaikaPossableColorsWhite;
            if (red < MaxValueForBlackColor && green < MaxValueForBlackColor && blue < MaxValueForBlackColor) {
                color = MazaikaPossableColorsBlack;
            }
            else if (red > MaxValueForRGBColors && blue > MaxValueForRGBColors && green > MaxValueForRGBColors) {
                color = MazaikaPossableColorsWhite;
            }
            else if (abs(sred - green) < GrayColorDelta && abs(sred - blue) < GrayColorDelta && abs(sred - red) < GrayColorDelta ) {
                color = MazaikaPossableColorsGray;
            }
            else if (blue < MaxValueForBlackColor && red - green > 0 && red - green < OrangeColorDelta ) {
                color = MazaikaPossableColorsOrange;
            }
            else if (red > green && red > blue) {
                color = MazaikaPossableColorsRed;
            }
            else if (green > blue) {
                color = MazaikaPossableColorsGreen;
            }
            else {
                color = MazaikaPossableColorsBlue;
            }
            
            [colors addObject:[self stringRepresentationFromMazaikaPossableColor:color]];
            
        }
    }

    if (data) { free(data); }
    
    return colors;
}

- (CGContextRef) createARGBBitmapContextFromImage:(CGImageRef)inImage
{
    CGContextRef    context = NULL;
    CGColorSpaceRef colorSpace;
    void *          bitmapData;
    int             bitmapByteCount;
    int             bitmapBytesPerRow;
    
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    bitmapBytesPerRow   = (pixelsWide * 4);
    bitmapByteCount     = (bitmapBytesPerRow * pixelsHigh);
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    
    if (colorSpace == NULL)
    {
        return NULL;
    }
    
    bitmapData = malloc( bitmapByteCount );
    if (bitmapData == NULL)
    {
        CGColorSpaceRelease( colorSpace );
        return NULL;
    }
    

    context = CGBitmapContextCreate (bitmapData,
                                     pixelsWide,
                                     pixelsHigh,
                                     8,
                                     bitmapBytesPerRow,
                                     colorSpace,
                                     kCGImageAlphaPremultipliedFirst);
    if (context == NULL)
    {
        free (bitmapData);
    }
    
    CGColorSpaceRelease( colorSpace );
    
    return context;
}

@end
